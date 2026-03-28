# 04_wave_detection.R
# This script detects waves in the influenza case data.

# Load necessary libraries
library(dplyr)
library(ggplot2)
library(zoo)
library(readr)

# Load the cleaned influenza case data
flu <- read_csv("data/processed/flu_clean.csv", show_col_types = FALSE)

## Create influenza season variable
flu <- flu %>%
  mutate(season_start = ifelse(week >= 40, year, year - 1),
         season_end = season_start + 1,
         season = paste0(season_start, "-", season_end))

# Keep only the main influena weeks

flu_seasonal <- flu %>%
  filter(week >= 40 | week <= 20) %>%
  arrange(date)

# Smooth weekly positives within each season
flu_seasonal <- flu_seasonal %>%
  group_by(season) %>%
  mutate(positive_smooth = zoo::rollmean(positive, k = 3, fill = NA, align = "center")) %>%
  ungroup()

# Save processed seasonal data
write_csv(flu_seasonal, "data/processed/flu_seasonal.csv")

# Plot 1: smoothed waves over time
p1 <- ggplot(flu_seasonal, aes(x = date, y = positive_smooth, color = season)) +
  geom_line(size = 1) +
  labs(title = "Detected Influenza Waves Over Time",
       x = "Date",
       y = "Smoothed Positives") +
  theme_minimal()

ggsave("output/figures/wave_detection_time_series.png", p1, width = 10, height = 6)


# Plot 2: one panel per season
p2 <- ggplot(flu_seasonal, aes(x = week, y = positive_smooth, color = season)) +
  geom_line(size = 1) +
  facet_wrap(~ season, ncol = 2) +
  labs(title = "Detected Influenza Waves by Season",
       x = "Week of Year",
       y = "Smoothed Positives") +
  theme_minimal()
ggsave("output/figures/wave_detection_by_season.png", p2, width = 12, height = 8)

# Create a wave summary table
wave_summary <- flu_seasonal %>%
  group_by(season) %>%
  summarise(
    peak_week = week[which.max(positive)],
    peak_date = date[which.max(positive)],
    peak_cases = max(positive, na.rm = TRUE),
    .group = "drop"
  )
write_csv(wave_summary, "output/tables/wave_summary.csv")

message("Wave detection completed. Plots saved to output/figures and summary table saved to output/tables.")
print(wave_summary)


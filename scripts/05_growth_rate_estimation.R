#05_growth_rate_estimation.R
# This script estimates the growth rate of influenza cases within each detected wave.

# Load necessary libraries
library(dplyr)
library(ggplot2)
library(zoo)
library(readr)

# Load the seasonal data from wave detection step
flu <- read_csv("data/processed/flu_seasonal.csv", show_col_types = FALSE)

# Select one season to analyse

# Choosen season: 2022-2023
flu_wave <- flu %>%
  filter(season == "2022-2023") %>%
  arrange(date)

# Select an early growth phase

growth_phase <- flu_wave %>%
  filter(date >= as.Date("2022-10-17"),
  date <= as.Date("2022-11-28")) %>%
  arrange(date)

  # Smooth weekly positives

growth_phase <- growth_phase %>%
  mutate(cases_smooth = zoo::rollmean(positive, k = 3, fill = NA, align = "center")) %>%
   filter(!is.na(cases_smooth))

# Create time index and log cases
growth_phase <- growth_phase %>%
mutate(time_index = row_number(),
log_cases = log(cases_smooth)) 


# Fit linear model to log cases
model <- lm(log_cases ~ time_index, data = growth_phase)

r_per_week <- unname(coef(model)[2])
r_per_day <- r_per_week / 7

# Save summary table
growth_summary <- tibble::tibble(
    season = "2022-2023",
    start_date = as.character(min(growth_phase$date)),
    end_date = as.character(max(growth_phase$date)),
    r_per_week = r_per_week,
    r_per_day = r_per_day
)

write_csv(growth_summary, "output/tables/growth_rate_summary.csv")

# Plot selected growth phase
p <- ggplot(growth_phase, aes(x = date, y = cases_smooth)) +
  geom_point() +
  geom_line() +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  labs(title = "Selected Growth Phase (2022-2023 Season)",
       x = "Date",
       y = "Smoothed positive detections") +
  theme_minimal()

ggsave("output/figures/growth_phase_selected.png", p, width = 10, height = 6)

# Plot log-linear fit
p2 <- ggplot(growth_phase, aes(x = time_index, y = log_cases)) +
  geom_point() +
  geom_line() +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  labs(title = "Log-Linear Growth Fit",
       x = "Time Index (weeks)",
       y = "Log(Smoothed positive detections)") +
  theme_minimal()

ggsave("output/figures/growth_rate_log_fit.png", p2, width = 10, height = 6)

# Print results
message("Growth rate estimation complete.")
message("Season analysed: 2022-2023")
message("Growth phase start: ", min(growth_phase$date))
message("Growth phase end: ", max(growth_phase$date))
message("Estimated growth rate per week (r): ", round(r_per_week, 4))
message("Estimated growth rate per day (r): ", round(r_per_day, 4))
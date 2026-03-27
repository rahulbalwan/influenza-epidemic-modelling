library(readr)
library(ggplot2)
library(dplyr)

# Read in the cleaned data
flu <- read_csv("data/processed/flu_clean.csv", show_col_types = FALSE)

# Create influenza season variable
flu <- flu %>%
  mutate(
    season_start = ifelse(week >= 40, year, year - 1),
    season_end = season_start + 1,
    season = paste0(season_start, "-", season_end)
  )

# Plot 1: Weekly cases over time
p1 <- ggplot(flu, aes(x = date, y = positive)) +
  geom_line(color = "blue") +
  labs(title = "Weekly Influenza Cases in the UK", x = "Date", y = "Number of Positive Cases") +
  theme_minimal()

ggsave("output/figures/flu_time_series.png", plot = p1, width = 10, height = 6)

# Plot 2: Cases by season
p2 <- ggplot(flu, aes(x = season, y = positive, colour = season)) +
  geom_line() +
  labs(title = "Influenza Cases by Season", x = "Week of year", y = "Number of Positive Cases",
  colour = "Season"
  )
ggsave("output/figures/flu_cases_by_season.png", plot = p2, width = 10, height = 6) 

# Plot 3: Faceted plot of cases by season
p3 <- ggplot(flu, aes(x = week, y = positive)) +
  geom_line() +
  facet_wrap(~ season) +
  labs(title = "Influenza Cases by Season", x = "Week", y = "Number of Positive Cases") +
  theme_minimal()
ggsave("output/figures/flu_cases_by_season_facet.png", plot = p3, width = 12, height = 8)

message("Exploratory analysis complete. Plots saved to output/figures/ directory.")

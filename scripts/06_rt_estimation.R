# 06_rt_estimation.R
# This script converts the estimated growth rate of influenza cases into an effective reproduction number (Rt).
# Load necessary libraries
library(dplyr)
library(readr)
library(tibble)

# Load growth rate summary
growth_summary <- read_csv("output/tables/growth_rate_summary.csv", show_col_types = FALSE)

# Make sure numeric columns are numeric
growth_summary <- growth_summary %>%
  mutate(r_per_week = as.numeric(r_per_week),
         r_per_day = as.numeric(r_per_day))

# Assume influenza generation time is 3 days
generation_time <- 3

# Calculate approximate reproduction number
rt_summary <- growth_summary %>%
  mutate(
    generation_time_days = generation_time,
    R_est = exp(r_per_day * generation_time)
  ) %>%
  select(
    season,
    start_date,
    end_date,
    r_per_week,
    r_per_day,
    generation_time_days,
    R_est
  )

# Save output
write_csv(rt_summary, "output/tables/rt_summary.csv")

# Print summary table
message("Estimated Rt summary:")
print(rt_summary)



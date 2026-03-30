# 06_rt_estimation.R
# This script converts the estimated growth rate of influenza cases into reproduction number (Rt) using the latent-period formula:
# R0 = (1 + r*latent_period) * (1 + r*infectious_period)

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

# Define generation time (latent period + infectious period) in days

latent_period <- 2
infectious_period <- 3

# Calculate approximate reproduction number
r0_summary <- growth_summary %>%
  mutate(
    latent_period_days = latent_period,
    infectious_period_days = infectious_period,
    R0_est = (1 + r_per_day * latent_period_days) * (1 + r_per_day * infectious_period_days)
  ) %>%
  select(
    season,
    start_date,
    end_date,
    r_per_week,
    r_per_day,
    latent_period_days,
    infectious_period_days,
    R0_est
  )

# Save output
write_csv(r0_summary, "output/tables/r0_summary.csv")

# Print summary table
message("Estimated R0 summary:")
print(r0_summary)



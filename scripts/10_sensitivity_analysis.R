# 10_sensitivity_analysis.R
# This script performs one-way sensitivity analysis for the SEIR model
# using the 2022-2023 influenza parameter estimates.
#
# It varies:
# - transmission rate (beta)
# - latent period
# - infectious period
#
# For each scenario, it records:
# - peak infectious population
# - time to peak
# - final epidemic size

# Load necessary libraries
library(deSolve)
library(dplyr)
library(readr)
library(ggplot2)
library(tibble)


# Load fitted parameter estimates

fit_summary <- read_csv(
  "output/tables/seir_model_fit_summary_growth_phase_2022_23.csv",
  show_col_types = FALSE
)

fitted_params <- read_csv(
  "output/tables/seir_model_fitted_parameters_growth_phase_2022_23.csv",
  show_col_types = FALSE
)

beta_base <- fit_summary$fitted_beta[1]

latent_period_base <- fitted_params$value[fitted_params$parameter == "latent_period"]
infectious_period_base <- fitted_params$value[fitted_params$parameter == "infectious_period"]


# Fixed settings

N <- 100000
time <- seq(0, 300, by = 1)

initial_state <- c(
  S = N - 1,
  E = 1,
  I = 0,
  R = 0
)


# Define SEIR model

seir_model <- function(time, state, parameters) {
  with(as.list(c(state, parameters)), {
    dS <- -beta * S * I / N
    dE <- beta * S * I / N - sigma * E
    dI <- sigma * E - gamma * I
    dR <- gamma * I
    list(c(dS, dE, dI, dR))
  })
}


# Simulation wrapper

run_seir <- function(beta, latent_period, infectious_period, initial_state, time, N) {
  sigma <- 1 / latent_period
  gamma <- 1 / infectious_period

  parameters <- c(
    beta = beta,
    sigma = sigma,
    gamma = gamma,
    N = N
  )

  out <- ode(
    y = initial_state,
    times = time,
    func = seir_model,
    parms = parameters
  )

  as.data.frame(out)
}


# Scenario grid

beta_values <- beta_base * c(0.8, 0.9, 1.0, 1.1, 1.2)
latent_values <- c(1, 2, 3, 4, 5)
infectious_values <- c(2, 3, 4, 5, 6)

scenario_grid <- bind_rows(
  tibble(
    parameter_varied = "beta",
    scenario_value = beta_values,
    beta = beta_values,
    latent_period = latent_period_base,
    infectious_period = infectious_period_base
  ),
  tibble(
    parameter_varied = "latent_period",
    scenario_value = latent_values,
    beta = beta_base,
    latent_period = latent_values,
    infectious_period = infectious_period_base
  ),
  tibble(
    parameter_varied = "infectious_period",
    scenario_value = infectious_values,
    beta = beta_base,
    latent_period = latent_period_base,
    infectious_period = infectious_values
  )
)


# Run scenarios

sensitivity_results <- scenario_grid %>%
  rowwise() %>%
  mutate(
    model_output = list(
      run_seir(
        beta = beta,
        latent_period = latent_period,
        infectious_period = infectious_period,
        initial_state = initial_state,
        time = time,
        N = N
      )
    ),
    peak_infectious = max(model_output$I),
    time_to_peak = model_output$time[which.max(model_output$I)],
    final_size = last(model_output$R)
  ) %>%
  ungroup() %>%
  select(
    parameter_varied,
    scenario_value,
    beta,
    latent_period,
    infectious_period,
    peak_infectious,
    time_to_peak,
    final_size
  )

# Save summary results
write_csv(
  sensitivity_results,
  "output/tables/seir_sensitivity_analysis_summary.csv"
)


# Save full model outputs

all_model_outputs <- scenario_grid %>%
  mutate(scenario_id = row_number()) %>%
  rowwise() %>%
  do({
    scenario <- .

    out <- run_seir(
      beta = scenario$beta,
      latent_period = scenario$latent_period,
      infectious_period = scenario$infectious_period,
      initial_state = initial_state,
      time = time,
      N = N
    )

    out %>%
      mutate(
        scenario_id = scenario$scenario_id,
        parameter_varied = scenario$parameter_varied,
        scenario_value = scenario$scenario_value,
        beta = scenario$beta,
        latent_period = scenario$latent_period,
        infectious_period = scenario$infectious_period
      )
  }) %>%
  ungroup()

write_csv(
  all_model_outputs,
  "output/models/seir_sensitivity_analysis_outputs.csv"
)

# Plot 1: Peak infectious vs scenario value

p1 <- ggplot(
  sensitivity_results,
  aes(x = scenario_value, y = peak_infectious)
) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  facet_wrap(~ parameter_varied, scales = "free_x") +
  labs(
    title = "Sensitivity Analysis: Peak Infectious Population",
    x = "Scenario value",
    y = "Peak infectious population"
  ) +
  theme_minimal()

ggsave(
  "output/figures/seir_sensitivity_peak_infectious.png",
  p1,
  width = 10,
  height = 6
)


# Plot 2: Time to peak vs scenario value

p2 <- ggplot(
  sensitivity_results,
  aes(x = scenario_value, y = time_to_peak)
) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  facet_wrap(~ parameter_varied, scales = "free_x") +
  labs(
    title = "Sensitivity Analysis: Time to Peak",
    x = "Scenario value",
    y = "Time to peak (days)"
  ) +
  theme_minimal()

ggsave(
  "output/figures/seir_sensitivity_time_to_peak.png",
  p2,
  width = 10,
  height = 6
)


# Plot 3: Final epidemic size vs scenario value

p3 <- ggplot(
  sensitivity_results,
  aes(x = scenario_value, y = final_size)
) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  facet_wrap(~ parameter_varied, scales = "free_x") +
  labs(
    title = "Sensitivity Analysis: Final Epidemic Size",
    x = "Scenario value",
    y = "Final epidemic size (Recovered at end)"
  ) +
  theme_minimal()

ggsave(
  "output/figures/seir_sensitivity_final_size.png",
  p3,
  width = 10,
  height = 6
)


# Plot 4: Infectious curves by scenario

p4 <- ggplot(
  all_model_outputs,
  aes(x = time, y = I, group = scenario_id, color = as.factor(scenario_value))
) +
  geom_line(linewidth = 1) +
  facet_wrap(~ parameter_varied, scales = "free_y") +
  labs(
    title = "Sensitivity Analysis: Infectious Curves",
    x = "Time (days)",
    y = "Number of infectious individuals",
    color = "Scenario"
  ) +
  theme_minimal()

ggsave(
  "output/figures/seir_sensitivity_infectious_curves.png",
  p4,
  width = 12,
  height = 7
)


# Print results
message("Sensitivity analysis complete.")
print(sensitivity_results)
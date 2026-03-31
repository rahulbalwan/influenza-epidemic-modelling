# 12_seasonal_sirs_model.R
# This script implements a seasonally forced SIRS model for influenza.
#
# Seasonal forcing is introduced through:
# beta(t) = beta0 * (1 + alpha * cos(2*pi*t/365))


# Load necessary libraries
library(deSolve)
library(ggplot2)
library(readr)
library(dplyr)
library(tibble)


# Load fitted transmission estimate

fit_summary <- read_csv(
  "output/tables/seir_model_fit_summary_growth_phase_2022_23.csv",
  show_col_types = FALSE
)

beta0 <- fit_summary$fitted_beta[1]


# Parameters

N <- 100000
infectious_period <- 3
immunity_duration <- 365

gamma <- 1 / infectious_period
omega <- 1 / immunity_duration

# Seasonal amplitude:
# 0 = no seasonality
# 0.2 to 0.4 is a reasonable exploratory range
alpha <- 0.25

parameters <- c(
  beta0 = beta0,
  gamma = gamma,
  omega = omega,
  alpha = alpha,
  N = N
)


# Initial conditions

initial_state <- c(
  S = N - 1,
  I = 1,
  R = 0
)


# Time grid

time <- seq(0, 3 * 365, by = 1)

# -----------------------------
# Seasonal SIRS model
# -----------------------------
seasonal_sirs_model <- function(time, state, parameters) {
  with(as.list(c(state, parameters)), {

    beta_t <- beta0 * (1 + alpha * cos(2 * pi * time / 365))

    dS <- -beta_t * S * I / N + omega * R
    dI <- beta_t * S * I / N - gamma * I
    dR <- gamma * I - omega * R

    list(c(dS, dI, dR), beta_t = beta_t)
  })
}


# Run model

seasonal_sirs_output <- ode(
  y = initial_state,
  times = time,
  func = seasonal_sirs_model,
  parms = parameters
)

seasonal_sirs_output <- as.data.frame(seasonal_sirs_output)


# Save model output

write_csv(
  seasonal_sirs_output,
  "output/models/seasonal_sirs_model_output.csv"
)


# Save parameter table

parameter_table <- tibble(
  parameter = c(
    "N",
    "beta0",
    "alpha",
    "infectious_period",
    "gamma",
    "immunity_duration",
    "omega",
    "S0",
    "I0",
    "R0_initial"
  ),
  value = c(
    N,
    beta0,
    alpha,
    infectious_period,
    gamma,
    immunity_duration,
    omega,
    initial_state["S"],
    initial_state["I"],
    initial_state["R"]
  )
)

write_csv(
  parameter_table,
  "output/tables/seasonal_sirs_parameters.csv"
)


# Summary metrics

peak_infectious <- max(seasonal_sirs_output$I, na.rm = TRUE)
time_to_peak <- seasonal_sirs_output$time[which.max(seasonal_sirs_output$I)]

final_susceptible <- tail(seasonal_sirs_output$S, 1)
final_infectious <- tail(seasonal_sirs_output$I, 1)
final_recovered <- tail(seasonal_sirs_output$R, 1)

seasonal_sirs_summary <- tibble(
  beta0 = beta0,
  alpha = alpha,
  gamma = gamma,
  omega = omega,
  peak_infectious = peak_infectious,
  time_to_peak = time_to_peak,
  final_susceptible = final_susceptible,
  final_infectious = final_infectious,
  final_recovered = final_recovered
)

write_csv(
  seasonal_sirs_summary,
  "output/tables/seasonal_sirs_summary.csv"
)


# Plot 1: Compartments

p1 <- ggplot(seasonal_sirs_output, aes(x = time)) +
  geom_line(aes(y = S, color = "Susceptible"), linewidth = 1) +
  geom_line(aes(y = I, color = "Infectious"), linewidth = 1) +
  geom_line(aes(y = R, color = "Recovered"), linewidth = 1) +
  labs(
    title = "Seasonally Forced SIRS Model",
    x = "Time (days)",
    y = "Number of individuals"
  ) +
  scale_color_manual(values = c(
    "Susceptible" = "green",
    "Infectious" = "red",
    "Recovered" = "blue"
  )) +
  theme_minimal() +
  theme(legend.title = element_blank())

ggsave(
  "output/figures/seasonal_sirs_all_compartments.png",
  plot = p1,
  width = 10,
  height = 6
)


# Plot 2: Infectious curve

p2 <- ggplot(seasonal_sirs_output, aes(x = time, y = I)) +
  geom_line(color = "red", linewidth = 1) +
  labs(
    title = "Seasonally Forced SIRS Model - Infectious Population",
    x = "Time (days)",
    y = "Number of infectious individuals"
  ) +
  theme_minimal()

ggsave(
  "output/figures/seasonal_sirs_infectious.png",
  plot = p2,
  width = 10,
  height = 6
)


# Plot 3: Seasonal transmission beta(t)

p3 <- ggplot(seasonal_sirs_output, aes(x = time, y = beta_t)) +
  geom_line(color = "purple", linewidth = 1) +
  labs(
    title = "Seasonal Transmission Rate beta(t)",
    x = "Time (days)",
    y = expression(beta(t))
  ) +
  theme_minimal()

ggsave(
  "output/figures/seasonal_sirs_beta_t.png",
  plot = p3,
  width = 10,
  height = 6
)


message("Seasonal SIRS model complete.")
print(seasonal_sirs_summary)
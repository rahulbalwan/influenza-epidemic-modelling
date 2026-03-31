# 09_model_fitting.R
# This script fits the SEIR model to the observed influenza data
# for the 2022-2023 season, focusing on the early growth phase.
#
# Main improvements:
# - fits only the early growth window where SEIR assumptions are more reasonable
# - uses better initial conditions based on the first observed value
# - fits observed cases to model incidence (sigma * E), not infectious prevalence (I)
# - estimates:
#     beta = transmission rate
#     rho  = scaling factor linking model incidence to observed detections

# Load necessary libraries
library(deSolve)
library(ggplot2)
library(readr)
library(dplyr)
library(tibble)
library(zoo)

# -----------------------------
# Load observed seasonal data
# -----------------------------
flu <- read_csv("data/processed/flu_seasonal.csv", show_col_types = FALSE)

# Select season and early growth phase
flu_fit <- flu %>%
  filter(season == "2022-2023") %>%
  filter(date >= as.Date("2022-10-17"),
         date <= as.Date("2022-11-28")) %>%
  arrange(date) %>%
  mutate(
    positive_smooth = zoo::rollmean(positive, k = 3, fill = NA, align = "center")
  ) %>%
  filter(!is.na(positive_smooth)) %>%
  select(date, week, positive, positive_smooth) %>%
  mutate(time = seq(0, by = 7, length.out = n()))

# -----------------------------
# Fixed epidemiological parameters
# -----------------------------
N <- 100000
latent_period <- 2
infectious_period <- 3

sigma <- 1 / latent_period
gamma <- 1 / infectious_period

# -----------------------------
# Initial conditions
# -----------------------------
# Use the first observed smoothed count to set more realistic initial conditions.
# Because observed positives are much smaller than true infections, divide by a rough factor.
initial_I <- max(1, round(flu_fit$positive_smooth[1] / 100))
initial_E <- initial_I
initial_R <- 0
initial_S <- N - initial_E - initial_I - initial_R

initial_state <- c(
  S = initial_S,
  E = initial_E,
  I = initial_I,
  R = initial_R
)

# -----------------------------
# Define SEIR model
# -----------------------------
seir_model <- function(time, state, parameters) {
  with(as.list(c(state, parameters)), {
    dS <- -beta * S * I / N
    dE <- beta * S * I / N - sigma * E
    dI <- sigma * E - gamma * I
    dR <- gamma * I
    list(c(dS, dE, dI, dR))
  })
}

# -----------------------------
# Simulation wrapper
# -----------------------------
run_seir <- function(beta, time, initial_state, sigma, gamma, N) {
  parameters <- c(beta = beta, sigma = sigma, gamma = gamma, N = N)

  out <- ode(
    y = initial_state,
    times = time,
    func = seir_model,
    parms = parameters
  )

  out <- as.data.frame(out)

  # Approximate model incidence:
  # new individuals becoming infectious per unit time
  out <- out %>%
    mutate(
      incidence = sigma * E
    )

  out
}

# -----------------------------
# Objective function
# -----------------------------
# par[1] = log(beta)
# par[2] = log(rho)
#
# observed positives ~ rho * model incidence
objective_function <- function(par, time, initial_state, sigma, gamma, N, observed_cases) {
  beta <- exp(par[1])
  rho  <- exp(par[2])

  model_out <- run_seir(
    beta = beta,
    time = time,
    initial_state = initial_state,
    sigma = sigma,
    gamma = gamma,
    N = N
  )

  predicted_cases <- rho * model_out$incidence
  sse <- sum((observed_cases - predicted_cases)^2, na.rm = TRUE)

  return(sse)
}

# -----------------------------
# Initial guesses
# -----------------------------
initial_beta <- 0.5
initial_rho <- 100
initial_par <- log(c(initial_beta, initial_rho))

# -----------------------------
# Optimisation
# -----------------------------
fit <- optim(
  par = initial_par,
  fn = objective_function,
  time = flu_fit$time,
  initial_state = initial_state,
  sigma = sigma,
  gamma = gamma,
  N = N,
  observed_cases = flu_fit$positive_smooth,
  method = "L-BFGS-B",
  lower = log(c(0.05, 0.01)),
  upper = log(c(2, 100000))
)

# -----------------------------
# Extract fitted parameters
# -----------------------------
fitted_beta <- exp(fit$par[1])
fitted_rho  <- exp(fit$par[2])
R0_est <- fitted_beta / gamma

# -----------------------------
# Run fitted model
# -----------------------------
fitted_model <- run_seir(
  beta = fitted_beta,
  time = flu_fit$time,
  initial_state = initial_state,
  sigma = sigma,
  gamma = gamma,
  N = N
) %>%
  mutate(
    predicted_cases = fitted_rho * incidence
  )

# -----------------------------
# Combine observed and fitted data
# -----------------------------
fit_results <- flu_fit %>%
  bind_cols(
    fitted_model %>% select(S, E, I, R, incidence, predicted_cases)
  ) %>%
  mutate(
    residual = positive_smooth - predicted_cases
  )

# -----------------------------
# Goodness-of-fit summaries
# -----------------------------
sse <- sum(fit_results$residual^2, na.rm = TRUE)
rmse <- sqrt(mean(fit_results$residual^2, na.rm = TRUE))
mae <- mean(abs(fit_results$residual), na.rm = TRUE)

peak_observed <- max(fit_results$positive_smooth, na.rm = TRUE)
peak_predicted <- max(fit_results$predicted_cases, na.rm = TRUE)

date_peak_observed <- fit_results$date[which.max(fit_results$positive_smooth)]
date_peak_predicted <- fit_results$date[which.max(fit_results$predicted_cases)]

# -----------------------------
# Save fitted results
# -----------------------------
write_csv(fit_results, "output/models/seir_model_fit_growth_phase_2022_23.csv")

# -----------------------------
# Save fitted parameter table
# -----------------------------
fit_parameter_table <- tibble(
  parameter = c(
    "N",
    "latent_period",
    "infectious_period",
    "sigma",
    "gamma",
    "fitted_beta",
    "fitted_rho",
    "R0_est",
    "S0",
    "E0",
    "I0",
    "R0_initial"
  ),
  value = c(
    N,
    latent_period,
    infectious_period,
    sigma,
    gamma,
    fitted_beta,
    fitted_rho,
    R0_est,
    initial_state["S"],
    initial_state["E"],
    initial_state["I"],
    initial_state["R"]
  )
)

write_csv(fit_parameter_table, "output/tables/seir_model_fitted_parameters_growth_phase_2022_23.csv")

# -----------------------------
# Save summary table
# -----------------------------
fit_summary <- tibble(
  season = "2022-2023",
  fit_window_start = as.character(min(flu_fit$date)),
  fit_window_end = as.character(max(flu_fit$date)),
  fitted_beta = fitted_beta,
  fitted_rho = fitted_rho,
  R0_est = R0_est,
  sse = sse,
  rmse = rmse,
  mae = mae,
  peak_observed = peak_observed,
  peak_predicted = peak_predicted,
  date_peak_observed = as.character(date_peak_observed),
  date_peak_predicted = as.character(date_peak_predicted),
  convergence_code = fit$convergence
)

write_csv(fit_summary, "output/tables/seir_model_fit_summary_growth_phase_2022_23.csv")

# -----------------------------
# Plot observed vs predicted cases
# -----------------------------
p1 <- ggplot(fit_results, aes(x = date)) +
  geom_line(aes(y = positive_smooth, color = "Observed"), linewidth = 1) +
  geom_point(aes(y = positive_smooth, color = "Observed"), size = 2) +
  geom_line(aes(y = predicted_cases, color = "Fitted"), linewidth = 1, linetype = "dashed") +
  labs(
    title = "SEIR Model Fit to Early Growth Phase (2022-2023 Season)",
    x = "Date",
    y = "Smoothed positive detections",
    color = "Series",
    caption = paste0(
      "Fitted R0: ", round(R0_est, 3),
      ", Fitted beta: ", round(fitted_beta, 3),
      ", Fitted rho: ", round(fitted_rho, 3)
    )
  ) +
  theme_minimal()

ggsave("output/figures/seir_model_fit_growth_phase_2022_23.png", p1, width = 10, height = 6)

# -----------------------------
# Plot residuals
# -----------------------------
p2 <- ggplot(fit_results, aes(x = date, y = residual)) +
  geom_line(linewidth = 0.8, color = "black") +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(
    title = "Residuals from SEIR Growth-Phase Fit",
    x = "Date",
    y = "Residual"
  ) +
  theme_minimal()

ggsave("output/figures/seir_model_residuals_growth_phase_2022_23.png", p2, width = 10, height = 6)

# -----------------------------
# Plot fitted compartments
# -----------------------------
p3 <- ggplot(fitted_model, aes(x = time)) +
  geom_line(aes(y = S, color = "Susceptible"), linewidth = 1) +
  geom_line(aes(y = E, color = "Exposed"), linewidth = 1) +
  geom_line(aes(y = I, color = "Infectious"), linewidth = 1) +
  geom_line(aes(y = R, color = "Recovered"), linewidth = 1) +
  labs(
    title = "Fitted SEIR Compartments (Growth Phase)",
    x = "Time (days)",
    y = "Number of Individuals"
  ) +
  scale_color_manual(values = c(
    "Susceptible" = "blue",
    "Exposed" = "orange",
    "Infectious" = "red",
    "Recovered" = "green"
  )) +
  theme_minimal() +
  theme(legend.title = element_blank())

ggsave("output/figures/seir_model_fitted_compartments_growth_phase_2022_23.png", p3, width = 10, height = 6)

# -----------------------------
# Print summary
# -----------------------------
message("SEIR growth-phase model fitting complete.")
message("Fitted beta: ", round(fitted_beta, 4))
message("Fitted rho: ", round(fitted_rho, 4))
message("Fitted R0: ", round(R0_est, 4))
message("RMSE: ", round(rmse, 4))
message("MAE: ", round(mae, 4))
message("Convergence code: ", fit$convergence)

print(fit_summary)
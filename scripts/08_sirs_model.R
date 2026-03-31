#08_sirs_model.R
# This script implements a simple SIRS (Susceptible-Infectious-Recovered-Susceptible) model to simulate the influenza epidemic dynamics, allowing for waning immunity and reinfection.

# Load necessary libraries
library(deSolve)
library(ggplot2)
library(readr)
library(dplyr)
library(tibble)

# Load R0 summary
r0_summary <- read_csv("output/tables/r0_summary.csv", show_col_types = FALSE)
R0_est <- r0_summary$R0_est[1] # Use the first season's R0 estimate for simulation

# SIRS model function
sirs_model <- function(time, state, parameters) {
  with(as.list(c(state, parameters)), {
    dS <- -beta * S * I / N + omega * R
    dI <- beta * S * I / N - gamma * I
    dR <- gamma * I - omega * R
    list(c(dS, dI, dR))
  })
}

# Parameters
N <- 100000 # Total population
infectious_period <- 3 # days
gamma <- 1 / infectious_period # Recovery rate
waning_immunity_period <- 365 # days
omega <- 1 / waning_immunity_period # Rate of losing immunity
beta <- R0_est * gamma # Transmission rate
parameters <- c(beta = beta, gamma = gamma, omega = omega, N = N)

# Initial conditions
initial_state <- c(S = N - 1, I = 1, R = 0)
# Time grid
time <- seq(0, 730, by = 1) # Simulate for 2 years
# Run the SIRS model
sirs_output <- ode(y = initial_state, times = time, func = sirs_model, parms = parameters)
sirs_output <- as.data.frame(sirs_output)

# Save model output
write_csv(sirs_output, "output/models/sirs_model_output.csv")
# Save parameter table
parameter_table <- tibble(
    parameter = c(
    "N",
    "infectious_period",
    "gamma",
    "waning_immunity_period",
    "omega",
    "R0_est",
    "beta",
    "S0",
    "I0",
    "R0_initial"
  ),
  value = c(
    N,
    infectious_period,
    gamma,
    waning_immunity_period,
    omega,
    R0_est,
    beta,
    initial_state["S"],
    initial_state["I"],
    initial_state["R"]
  )
)
write_csv(parameter_table, "output/models/sirs_model_parameters.csv")
# Plot SIRS model output
p1 <- ggplot(sirs_output, aes(x = time)) +
  geom_line(aes(y = S, color = "Susceptible")) +
  geom_line(aes(y = I, color = "Infectious")) +
  geom_line(aes(y = R, color = "Recovered")) +
  labs(title = "SIRS Model Simulation of Influenza Epidemic",
       x = "Time (days)",
       y = "Number of Individuals") +
  scale_color_manual(values = c("blue", "red", "green")) +
  theme_minimal() +
  theme(legend.title = element_blank())
ggsave("output/figures/sirs_model_all_compartments.png", p1, width = 10, height = 6)

# Plot infectious compartment only
p2 <- ggplot(sirs_output, aes(x = time, y = I)) +
  geom_line(color = "red") +
  labs(title = "Infectious Individuals Over Time (SIRS Model)",
       x = "Time (days)",
       y = "Number of Infectious Individuals") +
  theme_minimal()
ggsave("output/figures/sirs_model_infectious.png", p2, width = 10, height = 6)

# Create summary table
peak_infectious <- max(sirs_output$I)
time_to_peak <- sirs_output$time[which.max(sirs_output$I)]
final_susceptible <- tail(sirs_output$S, 1)
final_recovered <- tail(sirs_output$R, 1)
final_infectious <- tail(sirs_output$I, 1)
sirs_summary <- tibble(
  R0_est = R0_est,
  beta = beta,
  gamma = gamma,
  omega = omega,
  peak_infectious = peak_infectious,
  time_to_peak = time_to_peak,
  final_susceptible = final_susceptible,
  final_infectious = final_infectious,
  final_recovered = final_recovered
)
write_csv(sirs_summary, "output/tables/sirs_model_summary.csv")

message("SIRS model summary:")
print(sirs_summary)

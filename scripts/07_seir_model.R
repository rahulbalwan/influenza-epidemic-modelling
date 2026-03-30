# 07_seir_model.R
# This script implements a simple SEIR (Susceptible-Exposed-Infectious-Recovered) model to simulate the influenza epidemic dynamics based on the estimated reproduction number (R0) from the previous script.
# Load necessary libraries
library(deSolve)
library(ggplot2)
library(readr)
library(dplyr)
library(tibble)

# Load R0 summary
r0_summary <- read_csv("output/tables/r0_summary.csv", show_col_types = FALSE)
R0_est <- r0_summary$R0_est[1] # Use the first season's R0 estimate for simulation 

# SIER model function
seir_model <- function(time, state, parameters) {
  with(as.list(c(state, parameters)), {
    dS <- -beta * S * I / N
    dE <- beta * S * I / N - sigma * E
    dI <- sigma * E - gamma * I
    dR <- gamma * I
    list(c(dS, dE, dI, dR))
    })
}

# Parameters
N <- 100000 # Total population
latent_period <- 2 # days
infectious_period <- 3 # days
sigma <- 1 / latent_period # Rate of moving from exposed to infectious
gamma <- 1 / infectious_period # Recovery rate
beta <- R0_est * gamma # Transmission rate
parameters <- c(beta = beta, sigma = sigma, gamma = gamma,  N = N)

# Initial conditions
initial_state <- c(S = N - 1, E = 1, I = 0, R = 0)

# Time grid
time <- seq(0, 160, by = 1)
# Run the SEIR model
seir_output <- ode(y = initial_state, times = time, func = seir_model, parms = parameters)
seir_output <- as.data.frame(seir_output)

# Save model output
write_csv(seir_output, "output/models/seir_model_output.csv")

# Save parameter table
parameter_table <- tibble(
    parameter = c(
    "N",
    "latent_period",
    "infectious_period",
    "sigma",
    "gamma",
    "R0_est",
    "beta",
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
        R0_est,
        beta,
        initial_state["S"],
        initial_state["E"],
        initial_state["I"],
        initial_state["R"]
    )
)
write_csv(parameter_table, "output/tables/seir_parameters.csv")

# Plot all compartments
p1 <- ggplot(seir_output, aes(x = time)) +
  geom_line(aes(y = S, color = "Susceptible")) +
  geom_line(aes(y = E, color = "Exposed")) +
  geom_line(aes(y = I, color = "Infectious")) +
  geom_line(aes(y = R, color = "Recovered")) +
  labs(title = "SEIR Model Simulation", x = "Time (days)", y = "Number of Individuals") +
  scale_color_manual(values = c("blue", "orange", "red", "green")) +
  theme_minimal() +
  theme(legend.title = element_blank())
ggsave("output/figures/seir_model_all_compartments.png", plot = p1, width = 8, height = 6)
# Plot infectious compartment
p2 <- ggplot(seir_output, aes(x = time, y = I)) +
  geom_line(color = "red") +
  labs(title = "SEIR Model Simulation - Infectious Individuals", x = "Time (days)", y = "Number of Infectious Individuals") +
  theme_minimal()
ggsave("output/figures/seir_model_infectious.png", plot = p2, width = 8, height = 6)

# Create simples summary table of key outputs
peak_infectious <- max(seir_output$I)
time_to_peak <- seir_output$time[which.max(seir_output$I)]

seir_summary <- tibble(
  R0_est = R0_est,
  beta = beta,
  gamma = gamma,
  sigma = sigma,
  peak_infectious = peak_infectious,
  time_to_peak = time_to_peak
)
write_csv(seir_summary, "output/tables/seir_summary.csv")

# Print summary table
message("SEIR model summary:")
print(seir_summary)


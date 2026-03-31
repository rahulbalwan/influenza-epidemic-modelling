# 11_model_comparison.R
# This script compares the SEIR and SIRS model outputs
# for the influenza epidemic simulations.

# Load necessary libraries
library(readr)
library(dplyr)
library(ggplot2)
library(tibble)

# Load model outputs

seir_output <- read_csv("output/models/seir_model_output.csv", show_col_types = FALSE)
sirs_output <- read_csv("output/models/sirs_model_output.csv", show_col_types = FALSE)

seir_summary <- read_csv("output/tables/seir_summary.csv", show_col_types = FALSE)
sirs_summary <- read_csv("output/tables/sirs_model_summary.csv", show_col_types = FALSE)


# Add model labels

seir_output <- seir_output %>%
  mutate(model = "SEIR")

sirs_output <- sirs_output %>%
  mutate(model = "SIRS")


# Combine infectious outputs

infectious_comparison <- bind_rows(
  seir_output %>% select(time, I, model),
  sirs_output %>% select(time, I, model)
)

write_csv(
  infectious_comparison,
  "output/models/seir_sirs_infectious_comparison.csv"
)


# Build summary comparison table

comparison_summary <- tibble(
  model = c("SEIR", "SIRS"),
  peak_infectious = c(
    seir_summary$peak_infectious[1],
    sirs_summary$peak_infectious[1]
  ),
  time_to_peak = c(
    seir_summary$time_to_peak[1],
    sirs_summary$time_to_peak[1]
  ),
  final_susceptible = c(
    tail(seir_output$S, 1),
    sirs_summary$final_susceptible[1]
  ),
  final_infectious = c(
    tail(seir_output$I, 1),
    sirs_summary$final_infectious[1]
  ),
  final_recovered = c(
    tail(seir_output$R, 1),
    sirs_summary$final_recovered[1]
  )
)

write_csv(
  comparison_summary,
  "output/tables/seir_sirs_comparison_summary.csv"
)


# Plot 1: Infectious curves

p1 <- ggplot(infectious_comparison, aes(x = time, y = I, color = model)) +
  geom_line(linewidth = 1) +
  labs(
    title = "SEIR vs SIRS: Infectious Population Over Time",
    x = "Time (days)",
    y = "Number of infectious individuals",
    color = "Model"
  ) +
  theme_minimal()

ggsave(
  "output/figures/seir_sirs_infectious_comparison.png",
  p1,
  width = 10,
  height = 6
)


# Plot 2: Peak infectious comparison

p2 <- ggplot(comparison_summary, aes(x = model, y = peak_infectious, fill = model)) +
  geom_col(width = 0.6) +
  labs(
    title = "Peak Infectious Population: SEIR vs SIRS",
    x = "Model",
    y = "Peak infectious population"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

ggsave(
  "output/figures/seir_sirs_peak_comparison.png",
  p2,
  width = 8,
  height = 6
)


# Plot 3: Time to peak comparison

p3 <- ggplot(comparison_summary, aes(x = model, y = time_to_peak, fill = model)) +
  geom_col(width = 0.6) +
  labs(
    title = "Time to Peak: SEIR vs SIRS",
    x = "Model",
    y = "Time to peak (days)"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

ggsave(
  "output/figures/seir_sirs_time_to_peak_comparison.png",
  p3,
  width = 8,
  height = 6
)


# Plot 4: Final state comparison

final_state_long <- comparison_summary %>%
  select(model, final_susceptible, final_infectious, final_recovered) %>%
  tidyr::pivot_longer(
    cols = c(final_susceptible, final_infectious, final_recovered),
    names_to = "compartment",
    values_to = "value"
  )

p4 <- ggplot(final_state_long, aes(x = compartment, y = value, fill = model)) +
  geom_col(position = "dodge") +
  labs(
    title = "Final Epidemic State: SEIR vs SIRS",
    x = "Compartment",
    y = "Number of individuals",
    fill = "Model"
  ) +
  theme_minimal()

ggsave(
  "output/figures/seir_sirs_final_state_comparison.png",
  p4,
  width = 10,
  height = 6
)

message("SEIR vs SIRS comparison complete.")
print(comparison_summary)
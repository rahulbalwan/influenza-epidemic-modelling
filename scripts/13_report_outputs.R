# 14_make_report_outputs.R
# This script gathers the final tables and figures for report


# Load necessary libraries
library(readr)
library(dplyr)
library(tibble)
library(fs)


# Create report output folders

dir.create("report/figures", recursive = TRUE, showWarnings = FALSE)
dir.create("report/tables", recursive = TRUE, showWarnings = FALSE)


check_file <- function(path) {
  if (!file.exists(path)) {
    stop(paste("Required file not found:", path))
  }
}


# Define required source files

required_tables <- c(
  "output/tables/growth_rate_summary.csv",
  "output/tables/r0_summary.csv",
  "output/tables/seir_summary.csv",
  "output/tables/sirs_model_summary.csv",
  "output/tables/seir_model_fit_summary_growth_phase_2022_23.csv",
  "output/tables/seir_sensitivity_analysis_summary.csv",
  "output/tables/seir_sirs_comparison_summary.csv",
  "output/tables/seasonal_sirs_summary.csv"
)

required_figures <- c(
  "output/figures/flu_time_series.png",
  "output/figures/wave_detection_by_season.png",
  "output/figures/growth_phase_selected.png",
  "output/figures/growth_rate_log_fit.png",
  "output/figures/seir_model_all_compartments.png",
  "output/figures/seir_model_infectious.png",
  "output/figures/sirs_model_all_compartments.png",
  "output/figures/sirs_model_infectious.png",
  "output/figures/seir_model_fit_growth_phase_2022_23.png",
  "output/figures/seir_model_residuals_growth_phase_2022_23.png",
  "output/figures/seir_sensitivity_peak_infectious.png",
  "output/figures/seir_sensitivity_time_to_peak.png",
  "output/figures/seir_sensitivity_final_size.png",
  "output/figures/seir_sensitivity_infectious_curves.png",
  "output/figures/seir_sirs_infectious_comparison.png",
  "output/figures/seir_sirs_peak_comparison.png",
  "output/figures/seir_sirs_time_to_peak_comparison.png",
  "output/figures/seir_sirs_final_state_comparison.png",
  "output/figures/seasonal_sirs_all_compartments.png",
  "output/figures/seasonal_sirs_infectious.png",
  "output/figures/seasonal_sirs_beta_t.png"
)


# Validate files

invisible(lapply(required_tables, check_file))
invisible(lapply(required_figures, check_file))


# Copy key figures into report folder with clean names

figure_map <- tribble(
  ~source, ~destination,
  "output/figures/flu_time_series.png", "report/figures/Figure_1_time_series.png",
  "output/figures/wave_detection_by_season.png", "report/figures/Figure_2_wave_detection_by_season.png",
  "output/figures/growth_phase_selected.png", "report/figures/Figure_3_growth_phase_selected.png",
  "output/figures/growth_rate_log_fit.png", "report/figures/Figure_4_growth_rate_log_fit.png",
  "output/figures/seir_model_all_compartments.png", "report/figures/Figure_5_seir_all_compartments.png",
  "output/figures/seir_model_infectious.png", "report/figures/Figure_6_seir_infectious.png",
  "output/figures/sirs_model_all_compartments.png", "report/figures/Figure_7_sirs_all_compartments.png",
  "output/figures/sirs_model_infectious.png", "report/figures/Figure_8_sirs_infectious.png",
  "output/figures/seir_model_fit_growth_phase_2022_23.png", "report/figures/Figure_9_seir_growth_phase_fit.png",
  "output/figures/seir_model_residuals_growth_phase_2022_23.png", "report/figures/Figure_10_seir_growth_phase_residuals.png",
  "output/figures/seir_sensitivity_peak_infectious.png", "report/figures/Figure_11_sensitivity_peak_infectious.png",
  "output/figures/seir_sensitivity_time_to_peak.png", "report/figures/Figure_12_sensitivity_time_to_peak.png",
  "output/figures/seir_sensitivity_final_size.png", "report/figures/Figure_13_sensitivity_final_size.png",
  "output/figures/seir_sensitivity_infectious_curves.png", "report/figures/Figure_14_sensitivity_infectious_curves.png",
  "output/figures/seir_sirs_infectious_comparison.png", "report/figures/Figure_15_seir_vs_sirs_infectious.png",
  "output/figures/seir_sirs_peak_comparison.png", "report/figures/Figure_16_seir_vs_sirs_peak.png",
  "output/figures/seir_sirs_time_to_peak_comparison.png", "report/figures/Figure_17_seir_vs_sirs_time_to_peak.png",
  "output/figures/seir_sirs_final_state_comparison.png", "report/figures/Figure_18_seir_vs_sirs_final_state.png",
  "output/figures/seasonal_sirs_all_compartments.png", "report/figures/Figure_19_seasonal_sirs_compartments.png",
  "output/figures/seasonal_sirs_infectious.png", "report/figures/Figure_20_seasonal_sirs_infectious.png",
  "output/figures/seasonal_sirs_beta_t.png", "report/figures/Figure_21_seasonal_sirs_beta_t.png"
)

apply(figure_map, 1, function(x) file.copy(x[1], x[2], overwrite = TRUE))


# Copy key tables into report folder with clean names

table_map <- tribble(
  ~source, ~destination,
  "output/tables/growth_rate_summary.csv", "report/tables/Table_1_growth_rate_summary.csv",
  "output/tables/r0_summary.csv", "report/tables/Table_2_r0_summary.csv",
  "output/tables/seir_summary.csv", "report/tables/Table_3_seir_summary.csv",
  "output/tables/sirs_model_summary.csv", "report/tables/Table_4_sirs_summary.csv",
  "output/tables/seir_model_fit_summary_growth_phase_2022_23.csv", "report/tables/Table_5_seir_fit_summary.csv",
  "output/tables/seir_sensitivity_analysis_summary.csv", "report/tables/Table_6_sensitivity_summary.csv",
  "output/tables/seir_sirs_comparison_summary.csv", "report/tables/Table_7_seir_sirs_comparison.csv",
  "output/tables/seasonal_sirs_summary.csv", "report/tables/Table_8_seasonal_sirs_summary.csv"
)

apply(table_map, 1, function(x) file.copy(x[1], x[2], overwrite = TRUE))


# Load tables

growth_rate_summary <- read_csv("output/tables/growth_rate_summary.csv", show_col_types = FALSE)
r0_summary <- read_csv("output/tables/r0_summary.csv", show_col_types = FALSE)
seir_summary <- read_csv("output/tables/seir_summary.csv", show_col_types = FALSE)
sirs_summary <- read_csv("output/tables/sirs_model_summary.csv", show_col_types = FALSE)
seir_fit_summary <- read_csv("output/tables/seir_model_fit_summary_growth_phase_2022_23.csv", show_col_types = FALSE)
sensitivity_summary <- read_csv("output/tables/seir_sensitivity_analysis_summary.csv", show_col_types = FALSE)
comparison_summary <- read_csv("output/tables/seir_sirs_comparison_summary.csv", show_col_types = FALSE)
seasonal_sirs_summary <- read_csv("output/tables/seasonal_sirs_summary.csv", show_col_types = FALSE)


# Create one combined key results table

key_results <- tibble(
  analysis_step = c(
    "Growth rate estimation",
    "Reproduction number estimation",
    "SEIR simulation",
    "SIRS simulation",
    "SEIR growth-phase fitting",
    "SEIR vs SIRS comparison",
    "Seasonal SIRS simulation"
  ),
  key_result = c(
    paste0("r = ", round(growth_rate_summary$r_per_week[1], 3), " per week"),
    paste0("R0 = ", round(r0_summary$R0_est[1], 3)),
    paste0("Peak I = ", round(seir_summary$peak_infectious[1], 1),
           ", time to peak = ", round(seir_summary$time_to_peak[1], 0), " days"),
    paste0("Peak I = ", round(sirs_summary$peak_infectious[1], 1),
           ", time to peak = ", round(sirs_summary$time_to_peak[1], 0), " days"),
    paste0("beta = ", round(seir_fit_summary$fitted_beta[1], 3),
           ", R0 = ", round(seir_fit_summary$R0_est[1], 3),
           ", RMSE = ", round(seir_fit_summary$rmse[1], 1)),
    paste0("SEIR peak = ", round(comparison_summary$peak_infectious[comparison_summary$model == "SEIR"], 1),
           ", SIRS peak = ", round(comparison_summary$peak_infectious[comparison_summary$model == "SIRS"], 1)),
    paste0("Peak I = ", round(seasonal_sirs_summary$peak_infectious[1], 1),
           ", time to peak = ", round(seasonal_sirs_summary$time_to_peak[1], 0), " days")
  )
)

write_csv(key_results, "report/tables/Table_9_key_results_overview.csv")


# Create report figure manifest

figure_manifest <- tibble(
  figure_number = paste0("Figure ", 1:nrow(figure_map)),
  file_name = basename(figure_map$destination),
  description = c(
    "Weekly influenza cases over time",
    "Detected influenza waves by season",
    "Selected early growth phase",
    "Log-linear growth fit",
    "SEIR model compartment dynamics",
    "SEIR infectious curve",
    "SIRS model compartment dynamics",
    "SIRS infectious curve",
    "SEIR fit to early growth phase",
    "Residuals from SEIR growth-phase fit",
    "Sensitivity analysis: peak infectious population",
    "Sensitivity analysis: time to peak",
    "Sensitivity analysis: final epidemic size",
    "Sensitivity analysis: infectious curves",
    "SEIR vs SIRS infectious comparison",
    "SEIR vs SIRS peak infectious comparison",
    "SEIR vs SIRS time-to-peak comparison",
    "SEIR vs SIRS final epidemic state comparison",
    "Seasonal SIRS compartments",
    "Seasonal SIRS infectious curve",
    "Seasonal transmission rate beta(t)"
  )
)

write_csv(figure_manifest, "report/tables/figure_manifest.csv")


# Create report table 
table_manifest <- tibble(
  table_number = paste0("Table ", 1:9),
  file_name = c(
    "Table_1_growth_rate_summary.csv",
    "Table_2_r0_summary.csv",
    "Table_3_seir_summary.csv",
    "Table_4_sirs_summary.csv",
    "Table_5_seir_fit_summary.csv",
    "Table_6_sensitivity_summary.csv",
    "Table_7_seir_sirs_comparison.csv",
    "Table_8_seasonal_sirs_summary.csv",
    "Table_9_key_results_overview.csv"
  ),
  description = c(
    "Growth rate estimates",
    "Reproduction number estimates",
    "SEIR model summary",
    "SIRS model summary",
    "SEIR fit summary",
    "Sensitivity analysis summary",
    "SEIR vs SIRS comparison summary",
    "Seasonal SIRS summary",
    "Overview of key results"
  )
)

write_csv(table_manifest, "report/tables/table_manifest.csv")


report_checklist <- tibble(
  section = c(
    "Introduction",
    "Data and preprocessing",
    "Exploratory data analysis",
    "Wave detection",
    "Growth-rate estimation",
    "Reproduction number estimation",
    "SEIR modelling",
    "SIRS modelling",
    "SEIR model fitting",
    "Sensitivity analysis",
    "SEIR vs SIRS comparison",
    "Seasonal SIRS extension",
    "Discussion",
    "Limitations",
    "Conclusion"
  ),
  suggested_main_output = c(
    "No figure required",
    "Describe source and cleaned variables",
    "Figure 1, Figure 2",
    "Figure 2",
    "Figure 3, Figure 4, Table 1",
    "Table 2",
    "Figure 5, Figure 6, Table 3",
    "Figure 7, Figure 8, Table 4",
    "Figure 9, Figure 10, Table 5",
    "Figure 11-14, Table 6",
    "Figure 15-18, Table 7",
    "Figure 19-21, Table 8",
    "Table 9",
    "Use model caveats from text",
    "Table 9"
  )
)

write_csv(report_checklist, "report/tables/report_section_checklist.csv")

# Final message

message("Report outputs generated successfully.")

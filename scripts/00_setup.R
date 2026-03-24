# Required packaged
required_packages <- c(
  "tidyverse",
  "lubridate",
  "readxl",
  "janitor",
  "zoo",
  "deSolve",
  "tibble",
  "purrr",
  "ISOweek",
  "shiny",
  "plotly",
  "DT",
  "ggplot2",
  "dplyr",
  "readr"
)

# Install missing packages
missing_packages <- required_packages[
    !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]
if (length(missing_packages) > 0) {
  install.packages(missing_packages, repos = "http://cran.us.r-project.org")
}

# Load required packages
for (pkg in required_packages) {
  library(pkg, character.only = TRUE)
}

# create folder for data if it doesn't exist

dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)
dir.create("data/interim", recursive = TRUE, showWarnings = FALSE)
dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)
dir.create('data/metadata', recursive = TRUE, showWarnings = FALSE)

dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/models", recursive = TRUE, showWarnings = FALSE)

dir.create("docs", recursive = TRUE, showWarnings = FALSE)
dir.create("reports", recursive = TRUE, showWarnings = FALSE)

message("Setup complete. All required packages are installed and loaded, and necessary directories have been created.")

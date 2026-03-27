# Influenza Epidemic Modelling

This project analyses and models the transmission dynamics of influenza using weekly surveillance data from the United Kingdom.

It is structured as a **reproducible epidemiological analysis pipeline in R**, covering data ingestion, cleaning, exploratory analysis, epidemic growth estimation, and compartmental modelling.

---

## Objectives

* Explore influenza trends across multiple seasons
* Analyse epidemic growth phases
* Estimate growth rates and reproduction numbers
* Develop compartmental models (SEIR and SIRS)
* Perform sensitivity analysis
* Build an interactive Shiny dashboard

---

## Data

Data is sourced from **WHO FluNet**:

* Weekly influenza surveillance data
* Location: United Kingdom
* Time period: 2015–2026

### Outcome variable

* Weekly influenza positive detections

### Note on the data

The raw FluNet extract contains both:

* Positive detections
* Processed specimens

However, these variables were not internally consistent (e.g., positive counts exceeding processed counts in some weeks), making positivity rates unreliable.

Therefore, the current analysis is based on:

* **Weekly influenza positive detections**, rather than derived positivity measures.

---

## Project structure

```
project/
├── data/
│   ├── raw/          # Raw downloaded data
│   ├── interim/      # Intermediate transformed data
│   ├── processed/    # Clean, analysis-ready datasets
│   └── metadata/     # Data dictionaries and notes
├── scripts/          # Analysis and modelling scripts
├── output/
│   ├── figures/      # Saved plots (automatically generated)
│   ├── tables/       # Summary tables
│   └── models/       # Model outputs
├── docs/             # Assumptions and notes
├── report/           # Reports and summaries
├── app.R             # Planned Shiny dashboard (in progress)
└── run_all.R         # Master script to run full pipeline
```

> ⚠️ Note: The `output/` directory is not tracked in Git and is generated when the pipeline is executed.

---

## Workflow

The project follows a reproducible pipeline:

1. Data download
2. Data cleaning and transformation
3. Exploratory analysis
4. Epidemic growth estimation
5. Modelling and outputs generation

Figures and outputs are automatically saved to:

```
output/figures/
```

---

## Run order

To execute the full pipeline:

```r
source("run_all.R")
```

---

## Current status

🚧 This repository is under active development.

Current implemented scripts:

* `scripts/00_setup.R`
* `scripts/01_download_data.R`
* `scripts/02_clean_data.R`

Upcoming work:

* Epidemic growth modelling
* SEIR / SIRS implementation
* Sensitivity analysis
* Shiny dashboard

---

## Reproducibility

The project is designed with reproducibility in mind:

* Structured data pipeline (raw → processed)
* Script-based workflow
* Version control using Git
* Planned integration of automated outputs and dashboards

---

## Future extensions

* Real-time epidemic tracking
* Forecasting models
* Integration with additional surveillance datasets
* Interactive visualisation via Shiny

---

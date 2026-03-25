# Influenza Epidemic Modelling

This project aims to analyse and model the transmission dynamics of influenza using weekly surveillance data.

The project is designed as a reproducible epidemiological analysis pipeline in R, combining data cleaning, exploratory analysis, epidemic growth estimation, and compartmental modelling.

---

## Objectives

- Explore influenza trends across multiple seasons
- Analyse epidemic growth phases
- Estimate growth rates and reproduction numbers
- Develop compartmental models (SEIR and SIRS)
- Perform sensitivity analysis
- Build an interactive Shiny dashboard

---

## Data

Data is sourced from WHO FluNet:

- Weekly influenza surveillance data
- United Kingdom
- Time period: 2015–2026

At the current stage, the main outcome being used is:
- weekly influenza positive detections

## Note on the data
The raw FluNet extract contains both weekly positive detections and a field for processed specimens. However, these two variables were not internally consistent enough in the workflow to produce a reliable positivity measure, since positive counts often exceeded reported processed counts in the cleaned weekly totals.
For that reason, the current analysis is based primarily on:
- weekly influenza positive detections rather than positivity rates.

## Project structure

- `data/raw/` raw downloaded data
- `data/interim/` temporary transformed data
- `data/processed/` clean analysis-ready data
- `data/metadata/` data dictionaries and notes
- `scripts/` analysis and modelling scripts
- `output/figures/` figures
- `output/tables/` tables
- `output/models/` model outputs
- `docs/` assumptions, sources, and notes
- `report/` report drafts or summaries
- `app.R` The Shiny dashboard is planned but is not yet implemented. The current project stage focuses on data cleaning and exploratory analysis.
- Note: The `output/` folder is not tracked in Git, as it contains generated results that can be reproduced by running the scripts.


At current stage, the main scripts in use are:
- scripts/00_setup.R
- scripts/01_download_data.R
- scripts/02_clean_data.R

## Status
This repository is currently under active development


## Run order

The full workflow will be run from:

```r
source("run_all.R")


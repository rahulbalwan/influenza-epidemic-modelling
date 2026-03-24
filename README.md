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

## Run order

The full workflow will be run from:

```r
source("run_all.R")
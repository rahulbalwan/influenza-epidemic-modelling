# Influenza Epidemic Modelling

This project analyses and models the transmission dynamics of influenza using weekly surveillance data from the United Kingdom.

The work is structured as a **reproducible epidemiological analysis pipeline in R**, covering:

- data acquisition and cleaning  
- exploratory analysis  
- epidemic growth estimation  
- compartmental modelling (SIR/SIRS/SEIR)  
- sensitivity analysis  
- (planned) interactive Shiny dashboard  

---

## Objectives

- Explore influenza trends across multiple seasons  
- Understand epidemic structure and seasonal behaviour  
- Identify epidemic growth phases  
- Estimate growth rates and reproduction numbers  
- Develop and analyse compartmental models  
- Perform sensitivity analysis  
- Build an interactive Shiny dashboard (planned)  

---

## Data

Data is sourced from WHO FluNet:

- Weekly influenza surveillance data  
- Country: United Kingdom  
- Time period: 2015–2026  

### Key variables used

- `iso_year` → epidemiological year  
- `iso_week` → epidemiological week  
- `spec_processed_nb` → number of processed specimens  
- `inf_all` → number of influenza-positive detections  

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
* `scripts/03_exploratory_analysis.R`
* `scripts/04_wave_detection.R`


## Key findings:(EDA)
* Strong seasonal epidemic patterns
* Each year behaves as a separate epidemic event
* Epidemics follow a typical shape:
 * growth - peak - decline
* Large variability across seasons
* COVID-19 period shows suppressed influenza activity
* Post-pandemic seasons show resurgence

## Key findings: (wave detection)

* Influenza activity can be segmented into **distinct seasonal waves**  
* Peak intensity varies substantially between seasons  
* Recent seasons (e.g. 2022–2023) show unusually large epidemic peaks  
* Some seasons (e.g. 2020–2021) show minimal transmission
### Conceptual insight:

- The dataset represents: a sequence of repeated epidemic processes rather than a single continuous time series
- Each season corresponds to an independent epidemic with its own transmission dynamics.
---

## Reproducibility

The project is designed with reproducibility in mind:

* Structured data pipeline (raw → processed)
* Script-based workflow
* Version control using Git
* Planned integration of automated outputs and dashboards

## Learning notes

Detailed step-by-step reasoning and reflections are documented in:

- docs/learning-journal.md

## Tools used
- R
- tidyverse (dplyr, ggplot2, readr)
- janitor
- ISOweek
- zoo
- deSolve (for modelling)
---


## Author
Rahul 
- MSc Medical Statistics and Health Data Science, University of Bristol, United Kingdom
- MSc Statistics, Indian Institute of Technology Kanpur, India

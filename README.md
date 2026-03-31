# Influenza Epidemic Modelling

This project analyses and models the transmission dynamics of influenza using weekly surveillance data from the United Kingdom.

The work is structured as a **reproducible epidemiological analysis pipeline in R**, covering:

- data acquisition and cleaning
- exploratory data analysis
- epidemic wave detection
- epidemic growth estimation
- reproduction number estimation
- compartmental modelling (SEIR, SIRS, seasonal SIRS)
- model fitting
- sensitivity analysis
- interactive Shiny dashboard development

---

## Objectives

- Explore influenza trends across multiple seasons
- Understand epidemic structure and seasonal behaviour
- Identify epidemic growth phases
- Estimate growth rates and reproduction numbers
- Develop and analyse compartmental models
- Compare alternative mechanistic models
- Perform sensitivity analysis
- Build an interactive Shiny dashboard

---

## Data

Data is sourced from **WHO FluNet**.

- **Country:** United Kingdom  
- **Time period:** 2015–2026  
- **Frequency:** Weekly influenza surveillance data  

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
└── run_all.R         # Master script to run full pipeline
```

---

## Workflow

The project follows a reproducible workflow:

1. Data download  
2. Data cleaning and transformation  
3. Exploratory analysis  
4. Wave detection  
5. Epidemic growth estimation  
6. Reproduction number estimation  
7. Mechanistic modelling  
8. Model fitting  
9. Sensitivity analysis  
10. Model comparison  
11. Seasonal model extension  
12. Dashboard and report generation  

---

## Run the project

Run the full pipeline:

```r
source("run_all.R")

```
---
## Implemented scripts

- `00_setup.R`
- `01_download_data.R`
- `02_clean_data.R`
- `03_exploratory_analysis.R`
- `04_wave_detection.R`
- `05_growth_rate_estimation.R`
- `06_rt_estimation.R`
- `07_seir_model.R`
- `08_sirs_model.R`
- `09_model_fitting.R`
- `10_sensitivity_analysis.R`
- `11_model_comparison.R`
- `12_seasonal_sirs_model.R`
- `14_make_report_outputs.R`

---

## Key findings: Exploratory analysis

- Influenza shows strong **seasonal epidemic patterns**
- Each year behaves as a **separate epidemic**
- Epidemics follow a typical shape:
  - growth → peak → decline
- Large variability across seasons
- COVID-19 period shows suppressed influenza activity
- Post-pandemic seasons show resurgence

---

## Key findings: Wave detection

- Influenza activity can be segmented into **distinct seasonal waves**
- Peak intensity varies across seasons
- 2022–2023 shows a **large epidemic peak**
- Some seasons (e.g. 2020–2021) show minimal transmission

---

## Key findings: Growth rate

- Early epidemic phase follows **exponential growth**
- 2022–2023 estimates:
  - **r = 0.215 per week**
  - **r = 0.0307 per day**
- ~24% weekly increase
- Doubling time ≈ 23 days

---

## Key findings: Reproduction number

- **R₀ ≈ 1.16**
- Indicates **sustained but moderate transmission**
- Growth occurs because **R₀ > 1 over time**

---

## SEIR model (mechanistic simulation)

- Model structure: **S → E → I → R**
- Includes latent period

### Results

- Peak infectious: ~594  
- Time to peak: ~273 days  

### Interpretation

- Slow growth due to **R₀ slightly above 1**
- Produces a **single epidemic wave**

---

## SIRS model (waning immunity)

- Extends SEIR by adding **waning immunity**
- Transition: **Recovered → Susceptible**

### Results

- Peak infectious: ~1048  
- Time to peak: ~159 days  

### Interpretation

- Reinfection sustains transmission
- Infection persists at low levels
- More realistic for influenza dynamics

---

## SEIR model fitting (data-driven)

Fitted to **early growth phase (2022–2023)**

### Approach

- Observation model:
  - `cases ≈ ρ × (σE)`
- Estimated:
  - β (transmission rate)
  - ρ (scaling factor)

### Results

- β ≈ 0.402  
- R₀ ≈ 1.21  
- ρ ≈ 174  

### Performance

- RMSE ≈ 117  
- MAE ≈ 112  
- Captures **early exponential growth**

### Limitation

- Does not fit full epidemic curve
- No seasonality or behavioural change

---

## Sensitivity analysis

### Parameters varied

- β (transmission)
- latent period
- infectious period

### Key insights

- β and infectious period strongly affect epidemic size
- Latent period mainly affects timing
- Small parameter changes → large epidemic differences

---

## SEIR vs SIRS comparison

| Metric | SEIR | SIRS |
|------|------|------|
| Peak infectious | ~594 | ~1048 |
| Time to peak | 273 days | 159 days |
| Behaviour | single wave | persistent |

### Conclusion

- SEIR → short-term outbreaks  
- SIRS → long-term influenza dynamics  

---

## Seasonal SIRS model

Introduces **time-varying transmission**:

### Results

- Peak infectious: ~5057  
- Time to peak: ~1088 days  
- Produces **recurrent epidemic waves**

### Interpretation

- Combines:
  - waning immunity
  - seasonal forcing
- Most realistic influenza model in this project

---

## Overall insight

Influenza behaves as:

> **A recurrent seasonal epidemic driven by transmission, immunity, and environment**

### Model progression

- Growth rate → speed  
- R₀ → transmission  
- SEIR → single wave  
- SIRS → persistence  
- Seasonal SIRS → realistic cycles  

---

## Dashboard

The Shiny dashboard will include:

- EDA visualisations
- growth-phase model fitting
- sensitivity analysis
- model comparison
- seasonal SIRS simulation

### Features

- season selector
- downloadable plots/tables
- interactive comparisons

---

## Final scope

The project includes:

- data-driven modelling (growth phase)
- mechanistic simulation (SEIR, SIRS)
- seasonal modelling (seasonal SIRS)
- sensitivity analysis
- model comparison
- dashboard visualisation (Under Progress)

---

## Reproducibility

- Structured pipeline (raw → processed)
- Script-based workflow
- Version control
- Automated outputs


---

## Learning notes

See:
docs/learning-journal.md


---

## Tools used

- R
- tidyverse
- ggplot2
- deSolve
- shiny
- shinydashboard
- zoo
- janitor
- ISOweek

---

## Author

**Rahul**

- MSc Medical Statistics and Health Data Science, University of Bristol  
- MSc Statistics, IIT Kanpur  



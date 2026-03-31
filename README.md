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

### Key findings: Exploratory analysis

- Influenza shows strong **seasonal epidemic patterns**
- Each year behaves as a **separate epidemic**
- Epidemics follow a typical shape:
  - growth → peak → decline
- Large variability across seasons
- COVID-19 period shows suppressed influenza activity
- Post-pandemic seasons show resurgence

---

### Key findings: Wave detection

- Influenza activity can be segmented into **distinct seasonal waves**
- Peak intensity varies across seasons
- 2022–2023 shows a **large epidemic peak**
- Some seasons (e.g. 2020–2021) show minimal transmission

---

### Key findings: growth rate estimation

* Early epidemic phase follows approximately exponential growth *(Anderson and May, 1991)*  

* Estimated growth rate for 2022–2023 season:  
  * r = 0.215 per week  
  * r = 0.0307 per day  

* Corresponds to ~24% increase in cases per week  
* Estimated doubling time ≈ 23 days  

* Log-linear model provides a good fit during early growth phase, consistent with theoretical epidemic growth dynamics *(Wallinga and Lipsitch, 2007)*  
---

### Key findings: reproduction number estimation

* Estimated reproduction number for 2022–2023 early epidemic phase:  
  * R₀ ≈ 1.16  

* Indicates sustained but moderate transmission  

* Epidemic growth is driven by **R₀ > 1 over multiple weeks**, not high instantaneous transmission *(Diekmann et al., 1990)*  

* Even modest transmission rates can lead to large epidemic peaks if sustained over time *(Anderson and May, 1991)*  

## SEIR model (mechanistic simulation)

- Model structure: **S → E → I → R**
- Includes latent period

### Key findings:

* Implemented a mechanistic **SEIR compartmental model** *(Keeling and Rohani, 2008)*  

* Initial conditions:
  * one exposed individual (E = 1), rest susceptible  

* Model successfully reproduces:
  * gradual epidemic growth  
  * delayed peak (~273 days)  
  * realistic epidemic wave structure  

* Peak infectious population:
  * ~594 individuals (for N = 100,000)  

* Epidemic dynamics reflect:
  * slow growth due to **R₀ slightly above 1**  
  * extended time to peak due to moderate transmission  

* The SEIR framework captures infection progression through biologically meaningful stages *(Vynnycky and White, 2010)*  

### Interpretation

- Slow growth due to **R₀ slightly above 1**
- Produces a **single epidemic wave**

---

## SIRS model (waning immunity)

- Extends SEIR by adding **waning immunity**
- Transition: **Recovered → Susceptible**

### Key findings: (SIRS model simulation)

* Extended SEIR framework to a **SIRS model** by incorporating waning immunity *(Keeling and Rohani, 2008)*  

* Assumed:
  * immunity duration ≈ 365 days  

* Model produces:

  * Earlier and larger epidemic peak  
  * Peak infectious population:
    * ~1048 individuals  
  * Time to peak:
    * ~159 days  

* Infection persists at low levels due to **replenishment of susceptible individuals**  

* This behaviour is consistent with diseases exhibiting **waning immunity and reinfection**, such as influenza *(Grassly and Fraser, 2006)*  

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


### Key findings:

* The SEIR model was fitted to observed influenza data from the **2022–2023 season**, focusing on the **early epidemic growth phase**  

* The model was linked to observed case data using **incidence (σE)**, which better reflects new infections *(Keeling and Rohani, 2008)*  

* Estimated parameters:
  * β ≈ 0.402  
  * R₀ ≈ 1.21  
  * ρ ≈ 174  

* The model provides an excellent fit to the early growth phase  

* The early epidemic phase is the most reliable period for parameter estimation, as theoretical assumptions (exponential growth) hold *(Anderson and May, 1991)*  

* However, the model does not capture full epidemic dynamics due to simplifying assumptions:
  * constant transmission  
  * no seasonality  
  * homogeneous mixing  
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

### Key findings:

* Sensitivity analysis was performed to evaluate the effect of key parameters on epidemic dynamics *(Saltelli et al., 2008)*  

* Parameters explored:
  * transmission rate (β)  
  * latent period  
  * infectious period  

* Results show:

  * β and infectious period strongly influence epidemic size  
  * latent period primarily affects timing  

* Small changes in parameters can lead to large differences in epidemic outcomes  

* This highlights the importance of parameter uncertainty in epidemiological modelling *(Saltelli et al., 2008)*  
---

## SEIR vs SIRS comparison

| Metric | SEIR | SIRS |
|------|------|------|
| Peak infectious | ~594 | ~1048 |
| Time to peak | 273 days | 159 days |
| Behaviour | single wave | persistent |

### Key findings: 

* Comparison highlights the impact of **immunity assumptions** on epidemic dynamics  

* SEIR:
  * single epidemic wave  
  * infection eventually dies out  

* SIRS:
  * faster and larger epidemic  
  * persistent transmission  

* The inclusion of waning immunity allows:
  * recurrent outbreaks  
  * sustained infection levels  

* This aligns with influenza epidemiology, where immunity is temporary and reinfection occurs *(Shaman et al., 2010)*  
### Conclusion

- SEIR → short-term outbreaks  
- SIRS → long-term influenza dynamics  

---

## Seasonal SIRS model

Introduces **time-varying transmission**:

### Key findings: (Seasonal SIRS model)

* Introduced **time-varying transmission**:

  * β(t) = β₀ × (1 + α cos(2πt / 365))  

* Seasonal forcing is a key driver of influenza dynamics *(Grassly and Fraser, 2006)*  

* Model produces:
  * recurrent epidemic waves  
  * realistic seasonal patterns  

* Epidemic dynamics arise from the interaction of:
  * seasonal transmission  
  * waning immunity  

* This provides the most realistic representation of influenza behaviour in the project *(Shaman et al., 2010)*  

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



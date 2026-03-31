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

## Current implemented scripts:

* `scripts/00_setup.R`
* `scripts/01_download_data.R`
* `scripts/02_clean_data.R`
* `scripts/03_exploratory_analysis.R`
* `scripts/04_wave_detection.R`
* `scripts/05_growth_rate_estimation.R`
* `scripts/06_rt_estimation.R`

---

## Key findings: (EDA)

* Strong seasonal epidemic patterns  
* Each year behaves as a separate epidemic event  
* Epidemics follow a typical shape:  
  * growth - peak - decline  
* Large variability across seasons  
* COVID-19 period shows suppressed influenza activity  
* Post-pandemic seasons show resurgence  

---

## Key findings: (wave detection)

* Influenza activity can be segmented into **distinct seasonal waves**  
* Peak intensity varies substantially between seasons  
* Recent seasons (e.g. 2022–2023) show unusually large epidemic peaks  
* Some seasons (e.g. 2020–2021) show minimal transmission  

---

## Key findings: (growth rate estimation)

* Early epidemic phase follows approximately exponential growth  
* Estimated growth rate for 2022–2023 season:  
  * r = 0.215 per week  
  * r = 0.0307 per day  
* Corresponds to ~24% increase in cases per week  
* Estimated doubling time ≈ 23 days  
* Log-linear model provides a good fit during early growth phase  

---

## Key findings: (reproduction number estimation)

* Estimated reproduction number for 2022–2023 early epidemic phase:  
  * R0  ≈ 1.16  
* Indicates sustained but moderate transmission  
* Epidemic growth is driven by **R0 > 1 over multiple weeks**, not high instantaneous transmission  
* Even modest transmission rates can lead to large epidemic peaks if sustained over time  

---

## Key findings: (SEIR model simulation)

* Implemented a mechanistic **SEIR compartmental model** using estimated parameters  
* Initial conditions:
  * one exposed individual (E = 1), rest susceptible  
* Model successfully reproduces:
  * gradual epidemic growth  
  * delayed peak (~273 days)  
  * realistic epidemic wave structure  

* Peak infectious population:
  * ~594 individuals (for N = 100,000)  

* Epidemic dynamics reflect:
  * slow growth due to **R0 slightly above 1**  
  * extended time to peak due to moderate transmission  

---
## Key findings: (SIRS model simulation)

* Extended SEIR framework to a **SIRS model** by incorporating waning immunity  
* Assumed:
  * immunity duration ≈ 365 days  

* Model produces:

  * **Earlier and larger epidemic peak** compared to SEIR  
    * Peak infectious population:
      * ~1048 individuals  
    * Time to peak:
      * ~159 days  

* Key behavioural differences:

  * Susceptible population **recovers over time** due to loss of immunity  
  * Infection does **not fully disappear**  
  * System shows **persistent low-level transmission**

* Epidemic dynamics reflect:

  * Reinfection plays an important role in influenza transmission  
  * Even with **R₀ ≈ 1.16**, the disease can persist long-term  
  * Transmission is sustained through **continuous replenishment of susceptibles**

---

## Conceptual extension:

* Moving from SEIR → SIRS introduces a key epidemiological mechanism:

   **Waning immunity**

* This changes the interpretation of epidemic behaviour:

  * SEIR → single-wave epidemic  
  * SIRS → recurring / endemic dynamics  

* Highlights that:

  * Epidemic persistence depends not only on transmission (R₀)  
  * but also on **duration of immunity**

---

> Influenza behaves more like an **SIRS-type system** in reality, due to antigenic drift and waning immunity.
--- 
## Key findings: (SEIR model fitting)

* The SEIR model was fitted to observed influenza data from the **2022–2023 season**, focusing on the **early epidemic growth phase**.

### Model fitting approach

* The model was linked to observed case data using **incidence**, defined as:
  * σE (rate of transition from exposed to infectious)
* A scaling parameter (ρ) was introduced to account for:
  * under-reporting
  * differences between model population and surveillance data

* Parameters estimated:
  * transmission rate (β)
  * scaling factor (ρ)

---

### Fitted parameter estimates

* β ≈ 0.402  
* R₀ ≈ 1.21  
* ρ ≈ 174  

---

### Model performance

* The model provides an excellent fit to the early growth phase:
  * RMSE ≈ 117  
  * MAE ≈ 112  

* The model successfully captures:
  * exponential growth dynamics  
  * acceleration of cases during early epidemic phase  

---

### Peak timing

* Observed peak: **2022-11-21**  
* Predicted peak: **2022-11-21**  

* The model accurately reproduces the timing of epidemic growth during the fitting window  

---

### Interpretation

* The SEIR model is well-suited for modelling:
  * early epidemic growth  
  * transmission dynamics under near-exponential conditions  

* The estimated reproduction number (**R₀ ≈ 1.21**) confirms:
  * sustained but moderate transmission  

---

### Limitations

* The model does not accurately reproduce the **full epidemic curve**, including:
  * peak magnitude  
  * post-peak decline  

* This is due to simplifying assumptions:
  * constant transmission rate (β)  
  * homogeneous mixing  
  * no seasonal forcing  
  * no behavioural or policy changes  

---

### Key insight

* Mechanistic models must be applied to **appropriate epidemic phases**

* The early growth phase is:
  * the most reliable period for parameter estimation  
  * consistent with theoretical assumptions (exponential growth)

* Modelling the full epidemic requires:
  * time-varying transmission (β(t))  
  * seasonal effects  
  * extended models such as SIRS  

---

### Conclusion

* The SEIR model successfully bridges:
  * empirical estimates (growth rate, R₀)  
  * mechanistic epidemic dynamics  

* It provides a strong foundation for:
  * further model development  
  * sensitivity analysis  
  * more realistic epidemic modelling frameworks  
---

## Key findings: (SEIR sensitivity analysis)

* A one-way sensitivity analysis was performed using the **fitted SEIR model parameters** from the **2022–2023 growth phase**.

* The analysis examined how variation in key epidemiological parameters affects epidemic dynamics.

---

### Parameters explored

* Transmission rate (β)  
* Latent period (1–5 days)  
* Infectious period (2–6 days)  

* Each parameter was varied independently while keeping others fixed.

---

### Metrics evaluated

* Peak infectious population  
* Time to peak (days)  
* Final epidemic size (total recovered population)  

---

### Effects of transmission rate (β)

* Increasing β leads to:
  * higher peak infections  
  * faster epidemics (earlier peak)  
  * larger final epidemic size  

* At low β (~0.32):
  * epidemic barely grows  

* At higher β (~0.48):
  * rapid and large epidemic occurs  

---

### Effects of latent period

* Increasing latent period results in:
  * slower epidemic growth  
  * delayed peak timing  
  * reduced peak infectious population  
  * smaller final epidemic size  

---

### Effects of infectious period

* Increasing infectious period leads to:
  * significantly higher peak infections  
  * earlier epidemic peaks  
  * much larger epidemic size  

* Small increases in infectious duration produce:
  * disproportionately large changes in epidemic outcomes  

---

### Interpretation

* The SEIR model is most sensitive to:
  * transmission rate (β)  
  * infectious period  

* The latent period primarily affects:
  * timing and speed of the epidemic  
  * rather than overall magnitude  

---

### Key insight

* Epidemic outcomes are highly sensitive to parameter values  

* In particular:
  * small increases in transmission or infectious duration  
    → can lead to large increases in epidemic size  

* This highlights the importance of:
  * accurate parameter estimation  
  * understanding uncertainty in model inputs  

---

### Public health implication

* Reducing β (through interventions such as distancing or vaccination) can:
  * substantially reduce epidemic size  

* Reducing infectious period (through isolation or treatment) can:
  * significantly limit transmission  

---

### Conclusion

* Sensitivity analysis confirms that:
  * SEIR model behaviour is strongly driven by a small number of key parameters  

* It provides insight into:
  * which parameters matter most  
  * how uncertainty affects predictions  

* This strengthens confidence in:
  * model interpretation  
  * and guides future model extensions  

---

## Conceptual insight (Overall):

* The dataset represents a **sequence of repeated epidemic processes**, rather than a single continuous time series  
* Each season corresponds to an independent epidemic with its own transmission dynamics  

* Epidemic analysis requires:
  * identifying distinct epidemic waves  
  * isolating appropriate modelling phases  

* Reliable epidemic modelling depends on focusing on:
  * well-defined epidemic phases  
  * especially the early growth phase, where theoretical assumptions (e.g. exponential growth) hold  

* Mechanistic models (SEIR) provide:
  * a bridge between **data and transmission processes**  
  * a way to interpret parameters like:
    * growth rate (r)  
    * reproduction number (R0)  
    * latent and infectious periods  



---
## SEIR vs SIRS Model Comparison

### Objective

To compare the epidemic dynamics produced by the SEIR and SIRS models and assess how the inclusion of waning immunity changes model behaviour and interpretation.

---

### Comparison focus

* Compare the two models in terms of:
  * peak infectious population
  * time to peak
  * long-term epidemic behaviour
  * biological interpretation

---
## SEIR vs SIRS Model Comparison

### Objective

To compare the behaviour of the SEIR and SIRS models and evaluate which framework better captures influenza epidemic dynamics.

---

### Models compared

* **SEIR model**
  * Includes latent (exposed) stage
  * Assumes permanent immunity after recovery  

* **SIRS model**
  * Includes waning immunity
  * Allows recovered individuals to return to susceptible class  

---

### Comparison approach

The models were compared using:

* Infectious population over time  
* Peak infectious population  
* Time to peak  
* Final epidemic state (S, I, R compartments)  

---

### Key results

| Metric                  | SEIR        | SIRS        |
|------------------------|------------|------------|
| Peak infectious        | ~594       | ~1048      |
| Time to peak (days)    | 273        | 159        |
| Final susceptible      | ~81,053    | ~90,710    |
| Final infectious       | ~503       | ~184       |
| Final recovered        | ~18,120    | ~9,107     |

---

### Interpretation

* **SIRS produces:**
  * higher and earlier epidemic peak  
  * faster epidemic dynamics  
  * sustained infection levels over time  

* **SEIR produces:**
  * slower epidemic progression  
  * lower peak  
  * long-lasting depletion of susceptibles  

---

### Key differences

#### 1. Epidemic timing

* SIRS peaks **much earlier (159 days)**  
* SEIR peaks **much later (273 days)**  

→ Indicates that **waning immunity accelerates transmission cycles**

---

#### 2. Peak size

* SIRS peak is nearly **2× larger than SEIR**

→ Reinfection increases the number of infectious individuals  

---

#### 3. Long-term behaviour

* SEIR:
  * epidemic dies out  
  * immunity is permanent  

* SIRS:
  * infection persists at low levels  
  * susceptible population is replenished  

---

### Epidemiological relevance

* Influenza is **not permanently immunising**
* Immunity wanes over time
* Antigenic drift allows reinfection  

→ Therefore, **SIRS is more realistic for influenza modelling**

---

### Key insight

* Adding waning immunity fundamentally changes epidemic dynamics  

* SIRS better captures:
  * repeated outbreaks  
  * sustained transmission  
  * realistic influenza behaviour  

---

### Conclusion

* SEIR is useful for:
  * single-wave epidemic modelling  
  * short-term outbreak dynamics  

* SIRS is more appropriate for:
  * long-term influenza modelling  
  * seasonal and recurring epidemics  


---

### Conclusion

* Comparing SEIR and SIRS highlights the importance of immunity assumptions in epidemic modelling
* The SIRS model provides a more realistic conceptual framework for influenza persistence
* The SEIR model remains useful for analysing early epidemic growth and short-term wave dynamics
---

## Seasonal SIRS Model (Time-Varying Transmission)

### Objective

To extend the SIRS model by incorporating **seasonal forcing** in transmission and evaluate whether it can reproduce **recurrent influenza epidemic patterns** observed in long-term data (2015–2026).

---

### Model formulation

* The transmission rate was made time-dependent:

  * β(t) = β₀ × (1 + α cos(2πt / 365))

* This captures:
  * higher transmission in winter
  * lower transmission in summer

---

### Completed

* Implemented **seasonally forced SIRS model**
* Used fitted β₀ from SEIR growth-phase model
* Added **waning immunity (SIRS structure)**
* Simulated epidemic dynamics over multiple years (~3 years)

---

### Parameters

* β₀ ≈ 0.402  
* α = 0.25 (seasonal amplitude)  
* γ = 1/3 (infectious period = 3 days)  
* ω ≈ 0.00274 (immunity duration ≈ 1 year)  

---

### Results

* Peak infectious population:
  * ≈ 5057 individuals  

* Time to peak:
  * ≈ 1088 days (~3 years)

* Final state:
  * Susceptible ≈ 56,324  
  * Infectious ≈ 4,155  
  * Recovered ≈ 39,522  

---

### Key observations

* The model produces **recurrent epidemic waves**
* Epidemics are driven by:
  * seasonal increase in β(t)
  * replenishment of susceptibles via waning immunity

* Multiple peaks emerge naturally without forcing external shocks  

---

### Interpretation

* Compared to SEIR and basic SIRS:

  * SEIR:
    * single epidemic wave  
    * no long-term dynamics  

  * SIRS:
    * allows repeated outbreaks  
    * but lacks seasonal timing  

  * Seasonal SIRS:
    * reproduces **realistic influenza patterns**
    * aligns with observed yearly cycles  

---

### Key insight

* Influenza dynamics are driven by the combination of:
  * **seasonal transmission variation**
  * **waning immunity**

* Neither SEIR nor SIRS alone is sufficient:
  * SEIR → no recurrence  
  * SIRS → no seasonality  

* Seasonal SIRS provides:
  * the most realistic mechanistic explanation  

---

### Limitations

* Parameters not fitted to full time series
* Seasonal amplitude (α) chosen heuristically
* No stochasticity
* No age structure or contact heterogeneity
* No explicit observation/reporting model  

---

### Conclusion

* The seasonal SIRS model successfully captures:

  * repeated epidemic waves  
  * seasonal timing of outbreaks  
  * long-term influenza dynamics  

* This model represents a major improvement over:
  * SEIR (single-wave)
  * SIRS (non-seasonal)

---
### Final scope of modelling work

* The project was extended to a **seasonally forced SIRS model** to capture recurrent influenza-like dynamics

* This model successfully demonstrated:
  * repeated epidemic waves
  * the role of waning immunity
  * the effect of seasonal variation in transmission

* A full multi-year parameter fitting step was explored but not completed, because:
  * long-term seasonal model fitting is considerably more complex
  * it introduces numerical and identifiability challenges
  * it requires a more advanced calibration framework beyond the scope of the my current project understanding.

* Therefore, the project concludes with:
  * data-driven fitting for the early epidemic phase
  * and simulation-based seasonal SIRS modelling for long-term epidemic behaviour
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

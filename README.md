# Influenza Epidemic Modelling

![R](https://img.shields.io/badge/language-R-blue)
![Status](https://img.shields.io/badge/status-Completed-brightgreen)
![License](https://img.shields.io/badge/license-MIT-lightgrey)
![Focus](https://img.shields.io/badge/focus-Epidemiology-red)
![Methods](https://img.shields.io/badge/methods-SEIR%20%7C%20SIRS%20%7C%20Seasonal-orange)

**Modelling influenza as a seasonal epidemic using mechanistic models (SEIR → SIRS → seasonal SIRS) and real UK surveillance data.**

---

## 🚀 Project Summary

This project analyses and models influenza transmission dynamics in the United Kingdom (2015–2026) using a **reproducible epidemiological modelling pipeline in R**.

The work combines:

- statistical analysis (growth rate, R₀)  
- mechanistic modelling (SEIR, SIRS)  
- seasonal dynamics (time-varying transmission)  

### 🔑 Key result

→ Influenza behaves as a **seasonal SIRS system**, driven by:

- waning immunity  
- seasonal transmission variation  

---

## 🧠 Skills Demonstrated

- Time series analysis  
- Epidemiological modelling (SEIR, SIRS)  
- Differential equations (`deSolve`)  
- Parameter estimation (`optim`)  
- Sensitivity analysis  
- Data visualisation (`ggplot2`)  
- Dashboard development (`Shiny`)  

---

## 📊 Data

Source: **WHO FluNet**

- Weekly influenza surveillance data  
- Country: United Kingdom  
- Period: 2015–2026  

---

## ⚙️ Modelling Workflow
EDA → Wave detection → Growth rate (r)
→ Reproduction number (R₀)
→ SEIR model → SIRS model
→ Model fitting → Sensitivity analysis
→ Seasonal SIRS model


---

## 🔬 Key Findings

### Growth dynamics

- Early epidemic follows **exponential growth**  
- Growth rate (2022–2023):
  - r ≈ 0.215 per week  
  - ~24% weekly increase  
- Doubling time ≈ 23 days  

---

### Reproduction number

- R₀ ≈ 1.16  
- Indicates **sustained but moderate transmission**  
- Large epidemics can occur even when R₀ is only slightly above 1  

---

### SEIR model (mechanistic simulation)

- Models: **S → E → I → R**  
- Peak infectious: ~594  
- Time to peak: ~273 days  

→ Produces a **single epidemic wave**

---

### SIRS model (waning immunity)

- Models: **S → I → R → S**  
- Peak infectious: ~1048  
- Time to peak: ~159 days  

→ Produces:
- faster growth  
- larger peak  
- persistent transmission  

---

### 🔬 Model fitting (data-driven)

Fitted SEIR model to **early growth phase (2022–2023)**:

- β ≈ 0.402  
- R₀ ≈ 1.21  
- ρ ≈ 174  

Model performance:
- RMSE ≈ 117  
- MAE ≈ 112  

→ Successfully captures **early exponential growth**

---

### ⚙️ Sensitivity analysis

Parameters varied:
- β (transmission)  
- latent period  
- infectious period  

Key insights:
- β and infectious period strongly affect epidemic size  
- latent period mainly affects timing  
- small parameter changes → large epidemic differences  

---

### 🔁 SEIR vs SIRS comparison

| Metric | SEIR | SIRS |
|------|------|------|
| Peak infectious | ~594 | ~1048 |
| Time to peak | 273 days | 159 days |
| Behaviour | Single wave | Persistent |

→ SIRS better represents influenza dynamics  

---

### 🌦️ Seasonal SIRS model

Introduced time-varying transmission

Results:
- Peak infectious ≈ 5057  
- Time to peak ≈ 1088 days  
- Produces **recurrent epidemic waves**

→ Most realistic model in this project  

---

## 🧠 Conceptual Insight

Influenza behaves as a **recurrent seasonal epidemic system**, driven by:

- transmission dynamics (β)  
- recovery (γ)  
- waning immunity (ω)  
- seasonal forcing  

### Model progression
Growth rate → speed
R₀ → transmission
SEIR → single wave
SIRS → persistence
Seasonal SIRS → realistic cycles



---

## ⚠️ Limitations

- Deterministic models (no stochasticity)  
- No vaccination or intervention modelling  
- Seasonal model not fitted to full dataset  
- Parameter assumptions (latent period, immunity duration)  

---

## 📊 Dashboard

An interactive **Shiny dashboard** is included.

Features:
- EDA visualisations  
- model fitting results  
- sensitivity analysis  
- model comparison  
- seasonal simulation  

---


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


## Run the project

Run the full pipeline:

```r
source("run_all.R")

```
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


## License

This project is licensed under the MIT License – see the LICENSE file for details.
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


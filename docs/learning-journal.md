
# Setup Task

## Completed:

* Created a new project folder: `influenza-epidemic-modelling`
* Initialized Git repository
* Set up structured project directories:

  * `data/raw`, `data/processed`, `data/interim`
  * `scripts/`, `output/`, `docs/`, `report/`
* Added `.gitignore`
* Created initial `README.md`
* Created `learning-journal.md`
* Wrote `00_setup.R`:

  * installs required R packages
  * creates directory structure automatically
* Connected local project to GitHub

---

## Understanding:

* A reproducible workflow requires clear separation of:

  * raw data
  * processed data
  * scripts
  * outputs
* Git should be used from the beginning to track all changes
* Epidemiological modelling projects require structured pipelines
* The workflow will follow:

  * setup → cleaning → exploration → wave detection → growth estimation → modelling

---

## Next Step:

* Load and inspect raw influenza data
* Identify key variables and structure

---

# Data Loading & Inspection Task

## Completed:

* Downloaded influenza data from WHO FluNet (UK, 2015–2026)
* Saved dataset in `data/raw/flunet_uk.xlsx`
* Created `01_download_data.R` to validate file existence
* Loaded data using `read_excel()`
* Cleaned column names using `janitor::clean_names()`
* Inspected:

  * column names
  * structure
  * key variables

---

## Observations:

* Dataset contains weekly influenza surveillance data
* Key variables identified:

  * `iso_year`, `iso_week`
  * `spec_processed_nb` (tested)
  * `inf_all` (positive)
* Multiple rows exist per week
* Data is not structured as one observation per time point
* Variables may come from multiple reporting sources

---

## Understanding:

* Raw surveillance data is not analysis-ready
* Data represents reported detections, not true infections
* Multiple reporting streams may be combined in the dataset

---

## Next Step:

* Clean and restructure the dataset
* Convert it into a weekly time series

---

# Data Cleaning Task

## Completed:

* Created cleaning script `02_clean_data.R`
* Selected relevant variables:

  * year, week, tested, positive
* Converted all variables to numeric
* Created weekly date using ISO week format
* Aggregated data to one row per week
* Attempted to compute positivity

---

## Observations:

* Multiple rows per week required aggregation
* Found inconsistencies:

  * `tested = 0` with `positive > 0`
  * positivity = Inf
  * positivity > 1
* Even after aggregation:

  * `positive > tested` still occurred

---

## Understanding:

* `tested` and `positive` are not directly comparable
* Positivity is not a reliable measure in this dataset
* Data reflects complex reporting rather than a simple numerator-denominator structure

---

## Key Decision:

* Dropped positivity from analysis
* Selected:

  * **weekly positive detections** as main outcome variable

---

## Outcome:

* Created clean dataset:

  * one row per week
  * consistent time variable
* Saved to:

  * `data/processed/flu_clean.csv`

---

## Next Step:

* Perform exploratory analysis
* Understand epidemic patterns

---

# Exploratory Analysis Task

## Completed:

* Created script `03_exploratory_analysis.R`
* Loaded cleaned dataset
* Defined influenza seasons:

  * week 40 → week 20 (next year)
* Generated plots:

  * full time series
  * seasonal overlay
  * faceted seasonal plots

---

## Observations:

* Strong seasonal pattern (winter peaks)
* Each season shows:

  * growth → peak → decline
* Large variability across years
* COVID-19 period (2020–2021):

  * very low influenza activity
* Post-pandemic seasons:

  * unusually high peaks

---

## Understanding:

* Data is not one continuous time series
* It represents:

  * **repeated seasonal epidemics**
* Each season behaves like:

  * an independent epidemic event

---

## Key Insight:

* Modelling should not be done on full dataset
* It should focus on:

  * individual seasons
  * specific epidemic phases

---

## Next Step:

* Detect and structure epidemic waves

---

# Wave Detection Task

## Completed:

* Created script `04_wave_detection.R`
* Used seasonal classification
* Applied smoothing (rolling mean)
* Visualised epidemic waves
* Identified peaks for each season
* Created summary table:

  * peak week
  * peak date
  * peak cases

---

## Observations:

* Each season has a distinct epidemic wave
* Peak magnitude varies widely:

  * very low (2020–2021)
  * extremely high (2022–2023)
* Peak timing differs between seasons
* Some waves are more symmetric than others

---

## Understanding:

* Epidemics occur as:

  * **discrete waves**
* Each wave represents:

  * a separate transmission process
* External factors (e.g., COVID) affect wave size and timing

---

## Key Insight:

* The correct unit of analysis is:

  * **epidemic wave**, not full time series

---

## Outcome:

* Structured dataset into seasonal epidemic waves
* Identified best candidate for modelling:

  * 2022–2023 season

---

## Next Step:

* Estimate growth rate in early epidemic phase

---

# Growth Rate Estimation Task

## Completed:

* Created script `05_growth_rate_estimation.R`
* Selected 2022–2023 epidemic wave
* Chose early growth phase manually
* Applied smoothing (3-week rolling mean)
* Created:

  * time index
  * log-transformed cases
* Fitted model:

  * `log_cases ~ time_index`
* Generated plots:

  * growth phase
  * log-linear fit
* Saved summary table

---

## Observations:

* Growth phase shows increasing trend
* Log-transformed data shows near-linear relationship
* Estimated growth rate:

  * **r ≈ 0.215 per week**
  * **r ≈ 0.0307 per day**

---

## Interpretation:

* Epidemic follows **exponential growth** in early phase
* Cases increase:

  * ~24% per week
* Doubling time:

  * ~23 days

---

## Understanding:

* Early epidemic phase approximates:
  [
  I(t) = I_0 e^{rt}
  ]
* Log transformation allows:

  * linear regression estimation
* Growth rate reflects:

  * transmission intensity

---

## Key Insight:

* Only early growth phase should be used for estimation
* Full epidemic curve violates model assumptions

---

## Limitations:

* Growth phase selected manually
* Small number of observations
* Results sensitive to window selection

---

## Outcome:

* Successfully estimated epidemic growth rate
* Established first quantitative epidemic parameter

---

## Next Step:

* Convert growth rate to reproduction number (R)
* Begin compartmental modelling (SIR / SIRS)

---
# Reproduction Number Estimation Task

## Completed:

* Created script `06_r0_estimation.R`  
* Loaded growth rate estimates from previous step  
* Incorporated epidemiological structure:
  * **latent period = 2 days**
  * **infectious period = 3 days**  
* Applied SEIR-based relationship:
  * **R₀ = (1 + rL)(1 + rD)**  
* Generated summary table including:
  * season  
  * growth phase dates  
  * growth rate  
  * latent and infectious periods  
  * estimated reproduction number  

---

## Observations:

* Estimated reproduction number:
  * **R₀ ≈ 1.16**  
* Indicates epidemic is growing:
  * but at a **moderate rate**  
* Growth is sustained rather than explosive  

---

## Interpretation:

* Each infected individual generates:
  * ~**1.16 secondary infections**  
* Epidemic expansion occurs because:
  * **R₀ > 1 over multiple weeks**  
* Large epidemic peaks can arise even when:
  * **R₀ is only slightly above 1**  

---

## Understanding:

* Growth rate (**r**) describes:
  * **speed of epidemic increase**  
* Reproduction number (**R₀**) describes:
  * **transmission potential**  
* Relationship (SEIR framework):
  * **R₀ = (1 + rL)(1 + rD)**  
* Incorporating latent period improves:
  * biological realism of the model  
* R₀ provides a more interpretable:
  * epidemiological parameter than raw growth rate  

---

## Key Insight:

* Large epidemics do not require large R₀  
* Sustained transmission (**R₀ > 1**) is sufficient for significant outbreaks  
* Incorporating disease structure (latent + infectious stages):
  * improves interpretation of transmission dynamics  
* Early epidemic phase remains:
  * the most reliable window for parameter estimation  

---

## Limitations:

* Latent and infectious periods are assumed (not estimated from data)  
* R₀ is estimated from a selected growth window:
  * sensitive to phase selection  
* Does not capture:
  * time-varying transmission (true \(R_t\))  
* Based on simplified SEIR assumptions  

---

## Outcome:

* Successfully estimated reproduction number using a **mechanistically consistent approach**  
* Linked statistical growth estimates to **epidemiological theory (SEIR framework)**  
* Established a key transmission parameter (**R₀**) for use in:
  * compartmental modelling  

---

## Next Step:

* Implement compartmental models (SIR / SIRS)

---

# Overall Project Understanding

## Current Status:

* Setup completed
* Data cleaned and structured
* Epidemic patterns explored
* Waves identified
* Growth rate estimated
* Reproduction number estimated

---

## Key Conceptual Insight:

* The dataset represents:
  * **a sequence of repeated epidemic processes**
* Each season:
  * is an independent epidemic
  * has its own transmission dynamics

* Epidemic modelling workflow:
  1. Identify epidemic structure  
  2. Isolate epidemic phases  
  3. Estimate growth dynamics (r)  
  4. Translate to epidemiological parameters (R)  
  5. Move toward mechanistic models  

---
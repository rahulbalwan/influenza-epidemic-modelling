
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

## SEIR Model Simulation Task

### Completed:

* Created script `07_seir_model.R`  
* Loaded estimated reproduction number from previous step  
* Defined a deterministic **SEIR compartmental model**:
  * Susceptible  
  * Exposed  
  * Infectious  
  * Recovered  
* Set epidemiological parameters:
  * **latent period = 2 days**
  * **infectious period = 3 days**
  * **R₀ ≈ 1.16**
* Calculated:
  * \(\sigma = 1 / \text{latent period}\)
  * \(\gamma = 1 / \text{infectious period}\)
  * \(\beta = R_0 \times \gamma\)
* Chose initial conditions:
  * **S = N - 1**
  * **E = 1**
  * **I = 0**
  * **R = 0**
* Simulated the epidemic over time using `deSolve`
* Generated outputs:
  * all-compartment plot
  * infectious-only curve
  * parameter table
  * SEIR summary table  

---

### Observations:

* The infectious curve showed:
  * slow initial growth  
  * gradual acceleration  
  * a clear epidemic peak  
* Peak infectious population:
  * **~594 individuals**
* Time to peak:
  * **~273 days**
* Susceptible population declined gradually
* Recovered population increased steadily over time

---

### Interpretation:

* Since **R₀ > 1**, the epidemic is self-sustaining  
* Because **R₀ is only slightly above 1**, growth is:
  * **moderate rather than explosive**
* The epidemic peak occurs late because:
  * transmission is sustained
  * but not very strong  
* The model produces a plausible epidemic wave consistent with the earlier growth-rate and R₀ estimates  

---

### Understanding:

* The SEIR model represents infection progression as:
  * \(S \rightarrow E \rightarrow I \rightarrow R\)
* The exposed compartment introduces:
  * a biologically realistic delay before infectiousness
* Initialising with:
  * **one exposed person**
  makes the epidemic start in a mechanistically consistent way
* The relationship between parameters is:
  * \(\sigma = 1/L\)
  * \(\gamma = 1/D\)
  * \(\beta = R_0 \gamma\)

---

### Key Insight:

* Mechanistic models provide:
  * a bridge between **estimated parameters** and **epidemic behaviour**
* A modest reproduction number can still generate:
  * a large epidemic wave
  if transmission continues for long enough
* Model behaviour is shaped not only by \(R_0\), but also by:
  * latent period
  * infectious period
  * initial conditions

---

### Limitations:

* This is a **theoretical simulation**, not yet fitted directly to observed case counts  
* Population size is illustrative rather than data-derived  
* Initial conditions are assumed  
* Model does not yet include:
  * seasonality
  * stochastic effects
  * changing contact patterns
  * observation/reporting processes  

---

### Outcome:

* Successfully implemented a working SEIR model  
* Linked earlier empirical estimates (**r**, **R₀**) to a mechanistic transmission framework  
* Produced a full epidemic wave with:
  * interpretable parameters
  * meaningful epidemic dynamics  

---

### Next Step:

* Compare SEIR simulation with observed influenza data
* Explore model fit and possible extensions

---
## SIRS Model Simulation Task

### Completed:

* Created script `08_sirs_model.R`  
* Extended SEIR framework to include **waning immunity**  
* Defined a deterministic **SIRS compartmental model**:
  * Susceptible  
  * Infectious  
  * Recovered → Susceptible (loss of immunity)  

* Set epidemiological parameters:
  * **infectious period = 3 days**
  * **R₀ ≈ 1.16**
  * **immunity duration = 365 days**

* Calculated:
  * \(\gamma = 1 / \text{infectious period}\)  
  * \(\omega = 1 / \text{immunity duration}\)  
  * \(\beta = R_0 \times \gamma\)

* Initial conditions:
  * **S = N - 1**
  * **I = 1**
  * **R = 0**

* Simulated dynamics over time using `deSolve`
* Generated outputs:
  * all-compartment plot  
  * infectious curve  
  * parameter table  
  * SIRS summary table  

---

### Observations:

* The infectious curve showed:
  * a **faster and earlier peak** compared to SEIR  
  * peak infectious population:
    * **~1048 individuals**
  * time to peak:
    * **~159 days**

* After the initial wave:
  * infections decline  
  * but **do not go to zero**

* Susceptible population:
  * drops initially  
  * then **recovers over time**

* Recovered population:
  * increases  
  * then **declines due to waning immunity**

---

### Interpretation:

* The key difference from SEIR:
  **Immunity is temporary**

* This leads to:
  * replenishment of the susceptible pool  
  * continued low-level transmission  
  * potential for **recurrent waves**

* Unlike SEIR:
  * epidemic does **not fully die out**
  * system tends toward a **dynamic equilibrium**

---

### Understanding:

* The SIRS model represents:
  * \(S \rightarrow I \rightarrow R \rightarrow S\)

* New parameter introduced:
  * \(\omega\): rate of immunity loss  

* Dynamics are governed by:
  * \(\beta\): transmission  
  * \(\gamma\): recovery  
  * \(\omega\): waning immunity  

* Even with **R₀ only slightly above 1**:
  * long-term persistence becomes possible  
  * because susceptible individuals are continuously replenished  

---

### Key Insight:

* Adding waning immunity fundamentally changes epidemic behaviour:

| Model | Long-term behaviour |
|------|--------------------|
| SEIR | Single epidemic wave |
| SIRS | Persistent / recurring transmission |

* Epidemics are not just about **spread** — but also about:
   **how immunity evolves over time**

---

### Limitations:

* Immunity duration is assumed (365 days)  
* No seasonality included (important for influenza)  
* Deterministic model (no stochastic variability)  
* No vaccination or interventions  
* Not yet fitted to observed data  

---

### Outcome:

* Successfully extended the model to include **reinfection dynamics**  
* Demonstrated how **waning immunity sustains transmission**  
* Produced a more realistic long-term epidemic structure  

---

### Next Step:

* Fit model to observed data (**parameter estimation**)  
* Compare SEIR vs SIRS fits  
* Introduce seasonality and intervention effects  


## SEIR Model Fitting to Observed Data

### Objective

To connect the mechanistic SEIR model with real influenza surveillance data and evaluate how well the model explains observed epidemic dynamics.

---

### Completed

* Implemented parameter estimation using `optim()`
* Fitted SEIR model to **2022–2023 influenza season**
* Restricted fitting to **early epidemic growth phase**
* Defined observation model:
  * observed_cases ≈ ρ × (σE)

* Estimated parameters:
  * β (transmission rate)
  * ρ (scaling factor)

---

### Key methodological improvement

* Initial attempt used:
  * predicted_cases = ρ × I  
  → resulted in poor model fit  

* Corrected to:
  * predicted_cases = ρ × σE  
  → aligns with incidence (new infections)

* This change significantly improved model realism and fit quality  

---

### Results

* Estimated parameters:
  * β ≈ 0.402  
  * R₀ ≈ 1.21  
  * ρ ≈ 174  

* Model fit:
  * RMSE ≈ 117  
  * MAE ≈ 112  

* Peak timing:
  * accurately captured by the model  

---

### Observations

* The model:
  * closely follows observed data during early growth  
  * captures exponential increase in cases  

* However:
  * fails to reproduce full epidemic shape  
  * does not capture sharp peak and decline  

---

### Interpretation

* SEIR assumptions hold primarily during:
  * early epidemic phase  

* Later epidemic dynamics are influenced by:
  * depletion of susceptibles  
  * behavioural changes  
  * seasonal variation  
  * intervention effects  

---

### Key insight

* Model validity depends on alignment between:
  * theoretical assumptions  
  * epidemiological phase  

* Early growth phase is:
  * the most informative window for estimating transmission parameters  

* Using the correct observation model (incidence vs prevalence) is critical  

---

### Conceptual understanding

* SEIR structure:
  * S → E → I → R  

* Incidence corresponds to:
  * flow from E → I  

* Observed case data reflects:
  * new infections (incidence), not current infectious population  

---

### Limitations

* Deterministic model (no stochasticity)
* No seasonal forcing
* No time-varying transmission
* Population size assumed
* No explicit observation/reporting process beyond scaling factor  

---

### Learning outcome

* Successfully linked:
  * empirical data  
  * statistical estimation  
  * mechanistic modelling  

* Understood the importance of:
  * model–data alignment  
  * choosing correct epidemic phase  
  * interpreting fitted parameters carefully  

---

### Next steps

* Perform sensitivity analysis on key parameters:
  * β, σ, γ  

* Explore extended models:
  * SIRS (waning immunity)  
  * seasonal transmission  

* Compare model outputs with full epidemic curves  




# Overall Project Understanding

## Current Status:

* Setup completed
* Data cleaned and structured
* Epidemic patterns explored
* Waves identified
* Growth rate estimated
* Reproduction number estimated
* SEIR model implemented

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
  3. Estimate growth dynamics (**r**)  
  4. Translate to epidemiological parameters (**R₀**)  
  5. Build mechanistic models (**SEIR**)  
  6. Compare theory with observed epidemic behaviour  

---

## Sensitivity Analysis of SEIR Model

### Objective

To evaluate how changes in key epidemiological parameters influence the behaviour of the SEIR model and assess the robustness of model predictions.

---

### Completed

* Performed one-way sensitivity analysis on the SEIR model
* Used fitted parameters from the **2022–2023 growth phase**
* Varied key parameters:
  * β (transmission rate)
  * latent period
  * infectious period  

* Simulated epidemic trajectories for each scenario
* Computed summary metrics:
  * peak infectious population  
  * time to peak  
  * final epidemic size  

---

### Methodological approach

* Each parameter was varied independently while holding others constant  
* Parameter ranges:
  * β: ±20% around fitted value  
  * latent period: 1–5 days  
  * infectious period: 2–6 days  

* Used deterministic SEIR model to simulate epidemic dynamics over time  

---

### Results

* β variation:
  * strong impact on epidemic size and speed  
  * higher β → larger and faster epidemics  

* Latent period variation:
  * longer latent period → slower epidemic  
  * reduced peak and final size  

* Infectious period variation:
  * longer infectious period → very large increase in peak infections  
  * earlier peaks and significantly larger epidemic size  

---

### Observations

* Epidemic dynamics are highly sensitive to:
  * transmission rate  
  * infectious duration  

* Small parameter changes can lead to:
  * large differences in epidemic outcomes  

* Latent period mainly affects:
  * timing and delay of transmission  
  * rather than magnitude  

---

### Interpretation

* β controls:
  * how quickly infections spread  

* Infectious period controls:
  * how long individuals contribute to transmission  

* Latent period controls:
  * delay between exposure and infectiousness  

---

### Key insight

* Epidemic models are highly sensitive to parameter assumptions  

* In particular:
  * small increases in β or infectious period  
    → can lead to disproportionately large epidemics  

* This highlights the importance of:
  * accurate parameter estimation  
  * understanding uncertainty in model inputs  

---

### Conceptual understanding

* SEIR model behaviour depends on:
  * interaction between transmission (β), progression (σ), and recovery (γ)

* Epidemic size and timing are emergent properties of:
  * these interacting parameters  

* Sensitivity analysis helps identify:
  * which parameters dominate model behaviour  

---

### Limitations

* One-way sensitivity analysis only (no interaction effects)
* Deterministic model (no stochastic variation)
* No seasonal forcing
* Parameter ranges are assumed, not estimated from uncertainty distributions  

---

### Learning outcome

* Developed understanding of:
  * how model parameters influence epidemic behaviour  
  * which parameters are most critical  

* Recognised that:
  * model predictions are highly dependent on parameter values  

* Gained insight into:
  * robustness and uncertainty in epidemiological modelling  

---

### Next steps

* Extend to multi-parameter sensitivity analysis  
* Incorporate uncertainty ranges for parameters  
* Explore seasonal SEIR model  
* Compare sensitivity results with SIRS model dynamics  

## SEIR vs SIRS Model Comparison

### Objective

To understand how the inclusion of waning immunity changes epidemic behaviour and to compare the conceptual roles of the SEIR and SIRS models in influenza modelling.

---

### Completed

* Compared outputs from the SEIR and SIRS simulations
* Examined differences in:
  * peak infectious population
  * time to peak
  * long-term epidemic behaviour

---

### Results

* The SEIR model produced:
  * a smaller peak
  * a later peak
  * a single epidemic wave that eventually dies out

* The SIRS model produced:
  * a larger peak
  * an earlier peak
  * persistent low-level transmission after the main epidemic wave

---

### Observations

* Introducing waning immunity substantially changed model dynamics
* The epidemic became:
  * faster
  * larger
  * more persistent

* This showed that immunity assumptions strongly influence model behaviour

---

### Interpretation

* In the SEIR model:
  * recovered individuals are permanently removed from transmission

* In the SIRS model:
  * recovered individuals eventually re-enter the susceptible pool

* This replenishment of susceptibles allows:
  * continued transmission
  * potential recurrence of infection

---

### Key insight

* The difference between SEIR and SIRS is not only mathematical
* It changes the epidemiological meaning of the model

* SEIR is more suitable for:
  * a single epidemic wave

* SIRS is more suitable for:
  * infections like influenza, where immunity is temporary

---

### Conceptual understanding

* Epidemic dynamics depend not only on transmission rate
* They also depend on:
  * duration of immunity
  * whether recovered individuals remain protected

* Adding waning immunity makes the model more realistic for influenza

---

### Limitations

* The comparison is based on simulated outputs rather than fitted long-term data
* The SIRS model still does not include:
  * seasonality
  * strain variation
  * vaccination
  * behavioural change

---

### Learning outcome

* Understood how structural model assumptions affect epidemic behaviour
* Learned that immunity loss is a major mechanism shaping recurrent influenza transmission
* Recognised that model comparison is useful for linking biological realism to mathematical structure

---

### Next steps

* Compare SEIR and SIRS visually in a combined plot
* Explore whether SIRS better explains repeated seasonal influenza patterns
* Extend to seasonal transmission models

## SEIR vs SIRS Model Comparison

### Objective

To evaluate how different epidemiological assumptions (permanent vs waning immunity) affect epidemic dynamics and model behaviour.

---

### Completed

* Implemented both SEIR and SIRS models  
* Simulated epidemic trajectories for each model  
* Compared:
  * infectious curves  
  * peak size  
  * time to peak  
  * final epidemic state  

---

### Key observations

* The two models produce **qualitatively different epidemic behaviour**

#### SEIR model:
* Single epidemic wave  
* Slow increase and delayed peak  
* Infection eventually dies out  

#### SIRS model:
* Faster epidemic growth  
* Earlier and higher peak  
* Persistent low-level transmission  

---

### Key insight

* The inclusion of **waning immunity** dramatically changes model dynamics  

* In SIRS:
  * recovered individuals return to susceptible  
  * the population remains partially vulnerable  
  * infection can persist and re-emerge  

---

### Interpretation

* Influenza is characterised by:
  * antigenic drift  
  * partial immunity  
  * repeated seasonal outbreaks  

* Therefore:
  * SEIR assumptions are **too restrictive**  
  * SIRS provides a **more realistic representation**  

---

### Conceptual understanding

* SEIR assumes:
  * S → E → I → R (permanent immunity)

* SIRS assumes:
  * S → E → I → R → S (waning immunity)

* This feedback loop:
  * prevents full depletion of susceptibles  
  * enables ongoing transmission  

---

### Model behaviour insight

* Small structural changes in models can lead to:
  * large differences in epidemic outcomes  

* Key drivers of epidemic dynamics:
  * transmission rate (β)  
  * duration of infectiousness (γ⁻¹)  
  * immunity duration  

---

### Limitations

* Deterministic models (no stochastic variation)  
* No seasonal forcing (β constant)  
* No behavioural changes  
* No vaccination or intervention effects  

---

### Learning outcome

* Developed understanding of:
  * how model structure affects epidemic dynamics  
  * importance of biological realism in modelling  

* Learned that:
  * model assumptions must match disease characteristics  
  * otherwise predictions can be misleading  

---

### Key takeaway

* SEIR explains **single outbreaks**  
* SIRS explains **recurrent epidemics**  

* For influenza:
  * **SIRS is the more appropriate modelling framework**  

---

## Seasonal Forcing Extension

### What I did

* Extended the SIRS model by introducing **time-varying transmission β(t)**
* Implemented seasonal forcing using a cosine function
* Simulated long-term epidemic dynamics over multiple years  

---

### What I learned

* Real epidemic data (2015–2026) shows:
  * repeated seasonal waves  
  * not a single epidemic  

* This cannot be explained by:
  * SEIR → lacks recurrence  
  * basic SIRS → lacks timing  

---

### Key concepts

* Transmission is not constant:

  * β = β(t), not β = constant  

* Seasonal forcing is essential for diseases like influenza  

---

### Understanding the mechanism

* Epidemic waves arise from interaction of:

  1. Seasonal increase in β(t)
  2. Build-up of susceptible individuals (via waning immunity)

* This creates a **cycle**:

  * low transmission → susceptibles accumulate  
  * winter → transmission increases → outbreak  
  * recovery → immunity increases → decline  
  * immunity wanes → next wave possible  

---

### Insight from plots

* β(t) shows clear yearly oscillation  
* Infectious curve follows seasonal pattern  
* Multiple epidemic peaks emerge naturally  

---

### Why this matters

* This model aligns with real-world influenza epidemiology:

  * winter peaks  
  * annual cycles  
  * recurring outbreaks  

* It demonstrates how:

  * mechanistic models + realistic assumptions  
  → can reproduce observed data patterns  

---

### Key takeaway

* The most realistic influenza model in this project is:

  → **Seasonally forced SIRS model**

* It integrates:

  * transmission dynamics (β)  
  * recovery (γ)  
  * waning immunity (ω)  
  * environmental forcing (seasonality)  

---

### Next steps

* Fit seasonal model to full dataset (2015–2026)
* Estimate seasonal amplitude (α) from data
* Compare predicted vs observed multi-year trends
* Explore stochastic models for variability  

---

## Overall Project Insight (Final)

* Influenza is not a single epidemic:
  * it is a **recurrent seasonal process**

* Proper modelling requires:

  * time-varying transmission  
  * immune waning  
  * multi-year simulation  

* Model progression in this project:

  1. Growth rate (r) → early dynamics  
  2. SEIR → mechanistic single-wave model  
  3. SIRS → recurrent dynamics  
  4. Seasonal SIRS → realistic influenza model  

* Final understanding:

  → Epidemic patterns emerge from **mechanisms + environment**, not just data  

---
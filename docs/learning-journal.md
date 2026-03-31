# Learning Journal: Influenza Epidemic Modelling

This journal documents the reasoning, decisions, interpretation, and conceptual development behind the influenza epidemic modelling project. It reflects not only what was done at each step, but also why each step mattered and what was learned from it.

---

# 1. Project Setup and Reproducible Structure

## Objective

To create a clean, reproducible project structure that supports epidemiological analysis from raw surveillance data through to modelling, outputs, and reporting.

---

## What I completed

- Created a new project folder: `influenza-epidemic-modelling`
- Initialised a Git repository
- Created structured project directories:
  - `data/raw`
  - `data/interim`
  - `data/processed`
  - `data/metadata`
  - `scripts`
  - `output/figures`
  - `output/tables`
  - `output/models`
  - `docs`
  - `report`
- Added a `.gitignore`
- Created an initial `README.md`
- Created this `learning-journal.md`
- Wrote `00_setup.R` to:
  - install required packages
  - load required libraries
  - generate folders automatically
- Connected the local repository to GitHub

---

## Why this step mattered

Before doing any analysis, I wanted the project to be organised in a way that would support:

- reproducibility
- transparency
- version control
- clean separation between raw data, processed data, scripts, and outputs

This is especially important in epidemiological work because modelling decisions often depend on previous preprocessing steps. If the project is not structured well, it becomes difficult to trace how final results were produced.

---

## Interpretation and understanding

This stage made it clear that **good modelling begins long before model equations are written**. A project structure is not just administrative; it shapes the way analysis is conducted.

I understood that a reproducible workflow requires:

- raw data to remain unchanged
- processed data to be generated through scripts
- outputs to be regenerated automatically
- code to be version-controlled from the start

This also helped me think of the project as a **pipeline** rather than a sequence of disconnected tasks.

---

## Conceptual takeaway

At this point, I began to see epidemiological modelling as a layered workflow:

1. data acquisition
2. cleaning and structuring
3. understanding epidemic shape
4. extracting epidemiological quantities
5. translating those quantities into mechanistic models

That overall logic became the backbone of the project.

---

## Limitations / things noted

- Initial directory naming required some later cleanup for consistency (`output` vs `outputs`)
- At this stage, the workflow existed only as a project scaffold; the epidemiological meaning would emerge later

---

## Outcome

A reproducible and scalable project structure was successfully created, providing a foundation for all later data analysis and modelling.

---

# 2. Data Loading and Initial Inspection

## Objective

To load the raw influenza surveillance data, inspect its structure, identify relevant variables, and understand what kind of information the dataset actually contains.

---

## What I completed

- Downloaded WHO FluNet influenza data for the **United Kingdom**
- Covered the period **2015–2026**
- Saved the raw file in `data/raw/flunet_uk.xlsx`
- Created `01_download_data.R` to validate file existence
- Loaded the data using `read_excel()`
- Standardised column names using `janitor::clean_names()`
- Inspected:
  - column names
  - variable structure
  - key influenza reporting fields

---

## What I observed

The raw file contained weekly influenza surveillance data, but it was not in a simple “one row per week” format.

Important variables included:

- `iso_year`
- `iso_week`
- `spec_processed_nb`
- `inf_all`

I found that:

- multiple rows existed for the same week
- data appeared to come from multiple reporting channels or laboratory sources
- the dataset was not immediately suitable for time-series modelling

---

## Interpretation

This stage was important because it prevented me from making incorrect assumptions too early.

The raw data did **not** represent:

- one clean weekly observation
- direct measures of infection incidence
- a simple numerator-denominator surveillance structure

Instead, it represented **reported detections within a surveillance system**, which is a very different thing from true infections in the population.

This distinction became central later when I started fitting compartmental models. It reminded me that model states such as `I(t)` are not directly equivalent to observed positive counts.

---

## What I learned conceptually

This step deepened my understanding that surveillance data are:

- observational
- incomplete
- indirect
- shaped by reporting processes

In epidemiology, data do not speak for themselves. They must be interpreted in relation to what they actually measure.

This also raised an early modelling question:

> Am I modelling infections in the population, or detections within a surveillance system?

That question influenced many later decisions, especially in the model-fitting stage.

---

## Limitations / things noted

- The raw file did not explicitly explain why multiple rows existed per week
- Surveillance data structure implied some hidden complexity in reporting streams
- Direct interpretation of tested vs positive values needed caution

---

## Outcome

I identified the key variables needed for analysis and confirmed that the raw data would require substantial cleaning and restructuring before any epidemiological interpretation could begin.

---

# 3. Data Cleaning and Time-Series Construction

## Objective

To convert the raw surveillance data into a clean weekly time series suitable for exploratory analysis and modelling.

---

## What I completed

- Created `02_clean_data.R`
- Selected the key variables:
  - year
  - week
  - tested
  - positive
- Converted variables to numeric
- Constructed weekly dates using ISO week conventions
- Aggregated multiple rows into a single weekly observation
- Investigated positivity as a potential derived measure

---

## What I observed

Aggregation was necessary because multiple rows per week existed in the raw file.

While attempting to compute positivity (`positive / tested`), I encountered several issues:

- `tested = 0` with `positive > 0`
- positivity = `Inf`
- positivity > 1
- even after aggregation, `positive > tested` still occurred in some weeks

---

## Interpretation

This was a critical stage because it forced me to think carefully about **data validity** and **variable meaning**.

Initially, positivity seemed attractive because it could normalize case counts by testing effort. However, the inconsistencies showed that:

- `tested` and `positive` were not directly comparable in a simple way
- they may have originated from different reporting streams or data structures
- positivity would introduce misleading quantities rather than improve analysis

This was one of the most important early decisions in the project.

---

## Key analytical decision

I decided to **drop positivity from the analysis** and use:

> **weekly positive detections** as the main outcome variable

This decision improved clarity and avoided forcing a derived variable that the data structure did not support reliably.

---

## What I learned conceptually

Cleaning is not just technical formatting. It is part of **epidemiological reasoning**.

A key lesson here was:

> Not every available variable should be used.

The best variable is not always the most theoretically attractive one; it is the one that is:

- interpretable
- internally consistent
- defensible

Using weekly positives meant that later results would be interpreted as **detected influenza activity**, not exact infection incidence.

---

## Limitations / things noted

- Positive detections remain a proxy for true transmission
- Testing and reporting practices may have changed over time
- The cleaned series reflects surveillance intensity as well as disease activity

---

## Outcome

I created a consistent weekly dataset with:

- one row per week
- a proper time variable
- a clear outcome measure (`positive`)

This was saved as:

- `data/processed/flu_clean.csv`

---

# 4. Exploratory Data Analysis

## Objective

To understand the overall shape of influenza activity across years and determine whether the dataset should be analysed as one continuous time series or as repeated seasonal epidemics.

---

## What I completed

- Created `03_exploratory_analysis.R`
- Loaded the cleaned data
- Defined influenza seasons using:
  - week 40 to week 20 of the following year
- Generated:
  - full time-series plot
  - seasonal overlays
  - faceted plots by season

---

## What I observed

The results showed:

- strong winter seasonality
- a repeated pattern of:
  - growth
  - peak
  - decline
- large variability in peak size between years
- extremely low activity during 2020–2021
- strong resurgence after the COVID period

---

## Interpretation

This stage changed how I thought about the dataset.

At first glance, the data looked like a long time series from 2015 to 2026. But the plots showed that it is more meaningful to interpret the data as:

> **a sequence of repeated seasonal epidemics**

This is a major epidemiological distinction.

If I had treated the whole dataset as one continuous epidemic process, I would have ignored the fact that influenza re-emerges seasonally under changing conditions.

Instead, each season appeared to behave like its own epidemic event, with its own:

- initiation
- growth phase
- peak timing
- decline pattern
- intensity

---

## What I learned conceptually

This step taught me that the **unit of analysis matters**.

For influenza, the meaningful unit is not simply “time across many years,” but often:

- a season
- a wave
- a particular epidemic phase

This insight later justified:

- wave detection
- focusing on specific seasons
- fitting models only to selected windows such as the early growth phase

---

## Broader interpretation

The COVID-disrupted period was especially informative. It demonstrated that influenza dynamics are shaped not only by pathogen biology, but also by:

- social behaviour
- public health interventions
- contact structure
- environmental conditions

So even at the exploratory stage, it became clear that influenza is a **context-dependent epidemic system**, not just a pathogen spreading at a fixed rate.

---

## Limitations / things noted

- Seasonal definitions are somewhat conventional
- Seasonal comparison is descriptive at this stage, not yet mechanistic
- Surveillance intensity may vary across years

---

## Outcome

Exploratory analysis established that:

- influenza has strong seasonal epidemic structure
- seasons should be treated as distinct epidemic processes
- the modelling strategy should focus on individual waves and phases, not the full raw series

---

# 5. Wave Detection and Seasonal Structuring

## Objective

To explicitly structure the data into seasonal epidemic waves and identify the timing and intensity of peaks for each season.

---

## What I completed

- Created `04_wave_detection.R`
- Used the influenza season definition from exploratory analysis
- Applied smoothing using a rolling mean
- Visualised waves over time and by season
- Identified seasonal peaks
- Created summary outputs containing:
  - peak week
  - peak date
  - peak cases

---

## What I observed

Wave detection confirmed that:

- each influenza season has a distinct epidemic wave
- peak timing varies between seasons
- peak magnitude varies dramatically
- 2022–2023 had a particularly large wave
- 2020–2021 had almost no influenza signal

---

## Interpretation

This stage transformed descriptive seasonality into a more explicit **wave-based representation**.

Rather than simply saying “influenza is seasonal,” I could now characterise each season as a separate epidemic object.

This was useful because epidemic models are usually built around the idea of a wave or outbreak, not an arbitrarily long surveillance stream.

The 2022–2023 season emerged as the strongest candidate for modelling because it showed:

- a clear rise
- substantial signal
- a large peak
- an interpretable epidemic shape

---

## What I learned conceptually

Wave detection made the project more epidemiologically precise.

It clarified that the correct object for mechanistic modelling is not the whole surveillance record, but a defined epidemic episode.

This matters because quantities such as:

- growth rate
- reproduction number
- peak timing

must be interpreted within a specific epidemic context.

---

## Broader reflection

Wave detection also highlighted that epidemic timing is not fixed. Influenza does not simply peak on the same week every year. That variation suggested that:

- transmission is modulated by context
- epidemic timing emerges from both pathogen and environment
- a later seasonal model should account for time-varying transmission

---

## Outcome

The dataset was successfully restructured into seasonal waves, and the **2022–2023 season** was selected as the primary season for detailed modelling.

---

# 6. Growth Rate Estimation

## Objective

To estimate the exponential growth rate during the early phase of the 2022–2023 epidemic.

---

## What I completed

- Created `05_growth_rate_estimation.R`
- Selected the **2022–2023 season**
- Chose an early growth window manually
- Smoothed weekly positives using a rolling mean
- Created:
  - a time index
  - log-transformed case values
- Fitted the model:
  - `log_cases ~ time_index`
- Produced:
  - growth-phase plot
  - log-linear fit plot
  - summary table

---

## What I observed

The early growth phase showed:

- a clear increasing trend
- approximately linear behaviour on the log scale

Estimated growth rate:

- **r ≈ 0.215 per week**
- **r ≈ 0.0307 per day**

This corresponds to:

- approximately **24% weekly growth**
- doubling time of approximately **23 days**

---

## Interpretation

This was the first step where the project moved from descriptive analysis into quantitative epidemic inference.

The near-linearity of the log-transformed series supported the idea that the selected window approximates:

\[
I(t) = I_0 e^{rt}
\]

That matters because exponential growth is a core theoretical assumption used in early epidemic analysis.

The growth rate `r` is not yet a mechanistic parameter, but it is an important summary of how quickly the epidemic is expanding.

---

## What I learned conceptually

This step clarified the difference between:

- **epidemic shape**
- **epidemic speed**

The growth rate gives information about speed, not about the biological mechanism directly.

It also reinforced a major modelling principle:

> The early epidemic phase is often the only phase where simple theoretical assumptions hold reasonably well.

Once an epidemic approaches its peak, growth slows because of:

- depletion of susceptibles
- changing contact patterns
- behaviour change
- reporting dynamics

So the early growth window is special: it is the phase where clean estimation is most defensible.

---

## Important methodological reflection

The growth phase was selected manually. That means the result depends partly on judgement.

This is not necessarily a flaw, but it does mean the estimate is sensitive to:

- the chosen start date
- the chosen end date
- how strictly the phase resembles exponential growth

That made me more aware that epidemic estimation often involves both:

- statistical fitting
- epidemiological judgement

---

## Outcome

I successfully estimated the early epidemic growth rate and established the first key quantitative parameter for later transmission modelling.

---

# 7. Reproduction Number Estimation

## Objective

To convert the empirical growth rate into an epidemiologically interpretable transmission quantity: the reproduction number.

---

## What I completed

- Created `06_rt_estimation.R`
- Loaded the estimated growth rate
- Assumed:
  - latent period = 2 days
  - infectious period = 3 days
- Applied the SEIR-based approximation:

\[
R_0 = (1 + rL)(1 + rD)
\]

- Generated a summary table with:
  - growth phase dates
  - growth rate
  - latent period
  - infectious period
  - estimated reproduction number

---

## What I observed

Estimated reproduction number:

- **R₀ ≈ 1.16**

This indicates:

- transmission is above threshold
- the epidemic is growing
- transmission is sustained, but not explosive

---

## Interpretation

This was a major conceptual transition.

The growth rate `r` tells me:

- how fast the epidemic is increasing

The reproduction number `R₀` tells me:

- why it is increasing

With `R₀ ≈ 1.16`, each infected individual generates slightly more than one new infection on average. That may sound modest, but when sustained over multiple weeks it is enough to produce a substantial epidemic wave.

This was one of the most important interpretive moments in the project:

> Large epidemics do not require very high reproduction numbers; they require sustained transmission above threshold.

---

## What I learned conceptually

This step highlighted the difference between:

- descriptive epidemic speed
- mechanistic transmission potential

It also showed the importance of embedding data into a disease model framework. By using latent and infectious periods, I moved from a purely statistical estimate to a biologically interpretable quantity.

That made the project feel much more epidemiological rather than just statistical.

---

## Limitations / caution

- latent and infectious periods were assumed, not estimated from this dataset
- the formula is an approximation
- this is an estimate of transmission potential during the selected early phase, not a full time-varying \(R_t\) trajectory

Still, it was an appropriate and interpretable next step.

---

## Outcome

I successfully translated the growth estimate into a mechanistically meaningful transmission parameter, which became the basis for later compartmental models.

---

# 8. SEIR Model Simulation

## Objective

To use the estimated transmission parameters to build a mechanistic epidemic model that simulates infection dynamics over time.

---

## What I completed

- Created `07_seir_model.R`
- Built a deterministic **SEIR model**
- Compartments:
  - Susceptible
  - Exposed
  - Infectious
  - Recovered
- Used:
  - latent period = 2 days
  - infectious period = 3 days
  - \(R_0 \approx 1.16\)
- Calculated:
  - \(\sigma = 1/L\)
  - \(\gamma = 1/D\)
  - \(\beta = R_0 \gamma\)
- Set initial conditions:
  - \(S = N-1\)
  - \(E = 1\)
  - \(I = 0\)
  - \(R = 0\)
- Simulated dynamics with `deSolve`
- Saved:
  - compartment plots
  - infectious curve
  - parameter table
  - summary table

---

## What I observed

The SEIR model produced:

- slow initial growth
- gradual acceleration
- a clear epidemic peak
- steady decline after the peak

Summary:

- peak infectious population ≈ **594**
- time to peak ≈ **273 days**

---

## Interpretation

This was the stage where the project became a true mechanistic modelling exercise.

The SEIR model showed what the estimated transmission parameters imply dynamically. It translated abstract numbers such as `r` and `R₀` into an epidemic trajectory.

The result was instructive:

- even with only moderate transmission,
- a large wave can still emerge,
- but it emerges slowly

The late peak reflected the fact that transmission was only modestly above threshold.

---

## What I learned conceptually

The SEIR model introduced an important biological mechanism:

- the **latent compartment**

That means infections do not become infectious instantly. This delay adds realism and changes epidemic timing.

I also learned that model structure matters. Even with the same `R₀`, epidemic behaviour depends on:

- latent period
- infectious period
- initial conditions

So `R₀` alone does not determine epidemic shape.

---

## Broader insight

This was the first time I saw clearly how mechanistic models act as a bridge between:

- estimated parameters
- biological assumptions
- epidemic behaviour

That bridge became one of the strongest themes of the project.

---

## Limitations

- theoretical simulation only
- not yet fitted to observed case data
- population size was illustrative
- no seasonality
- no stochasticity
- no observation model
- no behaviour change

---

## Outcome

The SEIR model successfully connected empirical estimates to a mechanistic epidemic framework and showed how moderate transmission can still generate a substantial outbreak.

---

# 9. SIRS Model Simulation

## Objective

To extend the SEIR framework by incorporating **waning immunity** and investigate how this changes long-term epidemic behaviour.

---

## What I completed

- Created `08_sirs_model.R`
- Implemented a deterministic **SIRS model**
- Compartments:
  - Susceptible
  - Infectious
  - Recovered
  - Susceptible again through immunity loss
- Assumed:
  - infectious period = 3 days
  - immunity duration = 365 days
  - \(R_0 \approx 1.16\)
- Calculated:
  - \(\gamma = 1/D\)
  - \(\omega = 1/\text{immunity duration}\)
  - \(\beta = R_0 \gamma\)
- Set initial state:
  - \(S = N-1\)
  - \(I = 1\)
  - \(R = 0\)
- Simulated the model over time
- Saved plots and summary tables

---

## What I observed

Compared with SEIR, the SIRS model showed:

- a faster epidemic
- a higher peak
- an earlier time to peak
- persistent low-level infection after the main wave

Summary:

- peak infectious population ≈ **1048**
- time to peak ≈ **159 days**

---

## Interpretation

This was one of the clearest examples in the project of how changing one structural assumption can change everything.

The difference is not simply mathematical; it is epidemiological.

In SEIR:

- recovered individuals leave transmission permanently

In SIRS:

- recovered individuals eventually return to susceptibility

That means the susceptible pool is replenished, which allows transmission to continue.

This is much more consistent with influenza, where immunity is:

- incomplete
- temporary
- affected by antigenic drift

---

## What I learned conceptually

The SIRS model changed my understanding of what kind of system influenza really is.

SEIR is suitable for:

- a single epidemic wave
- a permanently immunising infection

SIRS is more suitable for:

- recurrent transmission
- infections with imperfect or waning immunity

This stage taught me that **model realism is often determined by structural assumptions**, not just parameter values.

---

## Important reflection

At this point I understood why influenza cannot be fully captured by a one-wave model. Seasonal influenza returns repeatedly, and any realistic long-term model must somehow allow transmission to restart.

Waning immunity is one such mechanism.

---

## Limitations

- immunity duration assumed, not estimated
- no seasonality
- no vaccination
- no strain replacement
- still not fitted to observed long-term data

---

## Outcome

The SIRS model demonstrated how immunity loss can sustain transmission and provided a more realistic conceptual model of influenza persistence.

---

# 10. SEIR Model Fitting to Observed Data

## Objective

To connect the mechanistic SEIR model directly to observed surveillance data and estimate model parameters from data rather than only simulating from assumed values.

---

## What I completed

- Implemented model fitting using `optim()`
- Focused on the **2022–2023 growth phase**
- Defined the observation model:

\[
\text{observed cases} \approx \rho \times (\sigma E)
\]

- Estimated:
  - \(\beta\) (transmission rate)
  - \(\rho\) (scaling factor)

---

## Important methodological correction

Initially I tried to relate observed cases to:

\[
\rho \times I
\]

This produced poor fits.

I then corrected the model to relate observed cases to:

\[
\rho \times \sigma E
\]

This was a much better choice because observed detections correspond more closely to **new infections becoming infectious** than to the current infectious population size.

This change made the model-data relationship much more coherent.

---

## What I observed

Estimated parameters:

- \(\beta \approx 0.402\)
- \(R_0 \approx 1.21\)
- \(\rho \approx 174\)

Model performance:

- RMSE ≈ **117**
- MAE ≈ **112**

The fit captured:

- early exponential growth
- correct timing of the growth-phase peak

But it did **not** reproduce the full season’s epidemic shape.

---

## Interpretation

This step was crucial because it showed that the SEIR model is most appropriate for:

- the early epidemic phase
- when exponential growth assumptions are approximately valid

It also showed that using the correct observation model is essential.

A mechanistic model can only fit well if the model state being compared to data actually corresponds to what the data measure.

This was one of the strongest methodological lessons in the project.

---

## What I learned conceptually

There are two separate challenges in epidemic modelling:

1. specifying biological dynamics correctly
2. linking those dynamics to what is actually observed

The second part is often underappreciated.

In this project, the surveillance data reflect **reported detections**, not direct counts of infectious individuals. That means the observation layer matters.

I also learned that model validity depends on aligning:

- the model structure
- the epidemic phase
- the observed variable

---

## Broader reflection

The fact that SEIR fit the growth phase but not the full epidemic was not a failure; it was a result.

It showed that:

- the early phase behaves approximately like a simple mechanistic epidemic
- the full season is affected by many additional forces:
  - seasonality
  - behaviour
  - susceptible depletion
  - changing contact rates
  - reporting effects

That result justified the later move toward more realistic models.

---

## Limitations

- deterministic model
- no seasonal forcing
- no stochasticity
- assumed population size
- no time-varying transmission
- simplified observation model

---

## Outcome

I successfully fitted the SEIR model to observed early-phase data and learned how important model–data alignment is in epidemiological inference.

---

# 11. Sensitivity Analysis

## Objective

To examine how sensitive SEIR model behaviour is to changes in key parameters and to identify which parameters most strongly influence epidemic outcomes.

---

## What I completed

- Performed one-way sensitivity analysis
- Used the fitted 2022–2023 growth-phase parameters as baseline
- Varied:
  - transmission rate \(\beta\)
  - latent period
  - infectious period
- Computed:
  - peak infectious population
  - time to peak
  - final epidemic size

---

## What I observed

Main findings:

- increasing \(\beta\):
  - increased epidemic size
  - increased peak height
  - caused earlier peaks
- increasing infectious period:
  - caused very large increases in epidemic burden
- increasing latent period:
  - slowed the epidemic
  - reduced peak size
  - reduced total epidemic size

---

## Interpretation

This stage showed that the SEIR model is particularly sensitive to:

- transmission intensity
- duration of infectiousness

This makes intuitive sense:

- higher transmission means infections spread more efficiently
- longer infectiousness means each infected person has more time to generate secondary infections

The latent period had a different effect. It mainly slowed the timing of spread rather than amplifying it.

---

## What I learned conceptually

Sensitivity analysis taught me that epidemic models are not just about point estimates. They are systems whose behaviour can change substantially under small parameter perturbations.

This is important because many epidemiological parameters are uncertain in real life.

So a model output is never just “the answer”; it is conditional on assumptions.

That changed how I interpreted compartmental models:

> A model is not only a prediction tool, but also a framework for understanding parameter dependence.

---

## Broader insight

This step also provided a public health interpretation.

If a disease is highly sensitive to transmission rate and infectious period, then interventions that reduce:

- contact rates
- transmission probability
- duration of infectiousness

can have disproportionately large epidemic effects.

So sensitivity analysis helped connect the mathematical model to intervention thinking.

---

## Limitations

- one-way sensitivity only
- no interaction effects
- deterministic framework
- no uncertainty distributions
- no seasonal forcing

---

## Outcome

I identified the parameters that most strongly govern epidemic magnitude and timing, and I gained a much stronger intuition for how compartmental models respond to epidemiological assumptions.

---

# 12. SEIR vs SIRS Comparison

## Objective

To compare the epidemic dynamics implied by permanent immunity (SEIR) versus waning immunity (SIRS), and assess which framework is more appropriate for influenza.

---

## What I completed

- Compared SEIR and SIRS simulation outputs
- Examined differences in:
  - peak size
  - time to peak
  - long-term behaviour
  - final epidemic state

---

## What I observed

SEIR produced:

- lower peak
- later peak
- a single epidemic wave
- no mechanism for recurrence

SIRS produced:

- higher peak
- earlier peak
- persistent low-level transmission
- ongoing vulnerability due to susceptibility replenishment

---

## Interpretation

This comparison made the role of immunity assumptions very clear.

The difference between SEIR and SIRS is not a small refinement; it changes the entire interpretation of the epidemic system.

In SEIR:

- immunity is effectively permanent
- transmission eventually exhausts itself

In SIRS:

- immunity decays
- the system can sustain or regenerate transmission

For influenza, this is much more plausible because influenza immunity is shaped by:

- waning immune protection
- partial cross-immunity
- viral evolution

---

## What I learned conceptually

I learned that model selection should follow disease biology.

SEIR is useful for:

- understanding a single outbreak wave
- capturing early epidemic dynamics

SIRS is better for:

- recurrent pathogens
- long-term persistence
- diseases where immunity is not permanent

This was one of the strongest examples in the project of how biological realism matters.

---

## Limitations

- comparison based on simulation outputs
- not a long-term fitted comparison
- no seasonal forcing in the basic SIRS version
- still simplified relative to real influenza epidemiology

---

## Outcome

This stage clarified that **SIRS is a more realistic long-term conceptual framework for influenza than SEIR**, even though SEIR remains useful for short-term epidemic analysis.

---

# 13. Seasonal Forcing Extension

## Objective

To incorporate time-varying transmission into the model and examine whether combining seasonality with waning immunity can generate realistic recurrent influenza-like dynamics.

---

## What I completed

- Extended the SIRS model with seasonal forcing
- Defined transmission as:

\[
\beta(t) = \beta_0 \left(1 + \alpha \cos\left(\frac{2\pi t}{365}\right)\right)
\]

- Simulated multi-year epidemic behaviour
- Explored how seasonal transmission interacts with waning immunity

---

## What I observed

The seasonal SIRS model produced:

- recurrent epidemic waves
- oscillating transmission over time
- epidemic peaks that arose naturally without manually restarting the model

This was the first model in the project that visually resembled the long-term seasonal character of influenza.

---

## Interpretation

This was the most realistic model in the project.

At this stage, the project moved beyond “one epidemic wave” and toward a genuine seasonal epidemic system.

The key mechanism became clear:

1. transmission rises seasonally
2. outbreaks occur
3. immunity builds
4. immunity wanes
5. seasonal transmission rises again
6. another outbreak becomes possible

This combination of:

- environmental forcing
- susceptible replenishment

is what makes influenza a recurrent seasonal process.

---

## What I learned conceptually

This step taught me that:

> Influenza dynamics are not driven by transmission alone.

They emerge from the interaction of:

- transmission
- immunity
- season

Neither SEIR alone nor non-seasonal SIRS alone fully captures that.

The seasonal SIRS model was the point where the project’s mechanistic explanation became most aligned with the observed data structure.

---

## Broader reflection

This stage also showed why long-term epidemic modelling is hard.

As soon as time-varying transmission is introduced, the model becomes:

- more realistic
- but also more difficult to fit and validate

That tension between realism and tractability became a recurring theme.

---

## Limitations

- seasonal amplitude chosen heuristically
- not fully calibrated to the entire multi-year series
- no stochasticity
- no strain structure
- no vaccination
- no age structure
- no explicit reporting layer

---

## Outcome

The seasonal SIRS model provided the strongest conceptual explanation of recurrent influenza dynamics in the project.

---

# 14. Decision on Scope and Stopping Point

## Objective

To assess whether full multi-year fitting of the seasonal SIRS model was feasible within the project and decide on a defensible endpoint.

---

## What I attempted

I explored fitting the seasonal SIRS model to the full multi-year surveillance series.

This introduced problems such as:

- numerical instability
- integration failure
- optimisation difficulties
- identifiability issues

---

## Interpretation

This was an important learning moment.

I realised that full long-term calibration of a seasonal epidemic model is not just “the next script”; it is a substantially more advanced modelling problem.

The challenge is not only computational. It is also conceptual.

Repeated influenza seasons are influenced by:

- seasonal forcing
- waning immunity
- viral evolution
- contact changes
- surveillance variation
- the COVID disruption period

So even if a model is biologically more realistic, that does not mean it is straightforward to fit.

---

## What I learned conceptually

This stage taught me a very important modelling lesson:

> A more realistic model is not always a more usable model.

Good modelling practice includes knowing when to stop, and when a simulation-based extension is more defensible than an unstable fitted model.

This decision did not weaken the project. In fact, it strengthened it, because it showed that I could distinguish between:

- meaningful extension
- overreaching complexity

---

## Outcome

I decided to stop at the **seasonal SIRS simulation stage**.

This was appropriate because the core conceptual objective had already been achieved:

- early growth dynamics were estimated from data
- short-term transmission was modelled mechanistically
- immunity loss was incorporated
- long-term recurrent seasonal behaviour was demonstrated

---

# 15. Dashboard Development

## Objective

To build an interactive Shiny dashboard that presents the main results of the project in a clear, visual, and accessible way.

---

## What I completed

- Developed a Shiny dashboard (`app.R`)
- Included tabs for:
  - Overview
  - EDA
  - Growth and Fit
  - Sensitivity Analysis
  - Model Comparison
- Added:
  - season selectors
  - download buttons
  - value boxes
  - interactive plot switching
  - project notes and interpretation labels

---

## Interpretation

The dashboard changed the project from a purely script-based workflow into an interactive analytical product.

This mattered because it allowed results to be:

- explored visually
- communicated more clearly
- connected across analysis stages

It also made me think differently about presentation. A dashboard forces you to decide:

- what the most important outputs are
- how a user navigates results
- which plots are most interpretable

---

## What I learned conceptually

I learned that communicating epidemic models is not only about equations and scripts. It is also about interface design and interpretability.

This stage also reinforced the importance of:

- linking outputs across stages
- making model comparison intuitive
- making assumptions explicit to the user

---

## Outcome

The dashboard became a final integration layer for the project, connecting data analysis, modelling, interpretation, and presentation in one place.

---

# 16. Final Overall Understanding

## What this project taught me

At the beginning, I thought of influenza data mainly as a time series to analyse. By the end, I understood it as a **seasonally recurring epidemic system**.

The project changed my perspective in several major ways.

### 1. The data are not a single epidemic

The full surveillance record is not best understood as one continuous epidemic, but as:

- repeated epidemic waves
- shaped by changing conditions
- requiring seasonal interpretation

### 2. Early epidemic phases are uniquely informative

The early growth phase is the part of the epidemic where:

- exponential growth assumptions are most reasonable
- transmission parameters are most identifiable
- simple models are most useful

### 3. Model structure matters as much as parameter values

A key lesson was that epidemic behaviour is shaped not only by:

- how large `R₀` is
- but by the structure of the model itself

Examples:

- SEIR adds latent delay
- SIRS adds immunity loss
- seasonal SIRS adds environmental forcing

Each structural change changes the interpretation of the epidemic.

### 4. Realistic modelling requires balancing complexity and tractability

A model can be:

- too simple to be realistic
- or too complex to fit reliably

The project taught me that good modelling lies in balancing:

- realism
- interpretability
- identifiability
- scope

### 5. Mechanistic models are explanatory tools

I now see compartmental models not just as predictive devices, but as tools for asking:

- what mechanism could produce this epidemic pattern?
- what assumption explains recurrence?
- what parameter controls timing versus size?

---

## Final project interpretation

The final conceptual picture that emerged is:

> Influenza is a recurrent seasonal epidemic process driven by the interaction of transmission, immunity, and environmental forcing.

The progression of models in this project reflects that understanding:

1. **Growth rate** → epidemic speed  
2. **Reproduction number** → transmission potential  
3. **SEIR** → mechanistic single-wave model  
4. **SIRS** → immunity loss and persistence  
5. **Seasonal SIRS** → recurrent influenza-like dynamics  

---

## Final personal learning outcome

This project helped me grow in three ways:

### Statistical understanding
I learned how to move from descriptive data analysis to parameter estimation.

### Epidemiological understanding
I learned how to interpret epidemic behaviour in terms of transmission, immunity, and phase structure.

### Modelling understanding
I learned that model choice is not just technical. It reflects biological assumptions, data limitations, and analytic goals.

---

## Closing reflection

The most important lesson from this project is that epidemic modelling is not simply about fitting curves.

It is about:

- understanding what the data represent
- identifying which assumptions are valid in which phase
- selecting models that match the disease process
- interpreting results within the limits of both the data and the model

That shift — from “running models” to **thinking mechanistically and critically about epidemics** — is the biggest thing I learned from this work.
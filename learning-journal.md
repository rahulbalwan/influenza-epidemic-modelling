

## Project setup

### Goal
Set up a clean and reproducible project structure for influenza epidemic modelling.

---

### What I did
- Created a GitHub repository: influenza-epidemic-modelling
- Designed a structured project layout:
  - data folders (raw, processed, interim)
  - scripts for analysis
  - output folders for figures and models
- Connected local project to GitHub using Git
- Created initial README and documentation files
- Wrote and ran the setup script (00_setup.R)
  - Installed required R packages
  - Created necessary directories automatically

---

### Next step
- Load and inspect raw influenza data
- Clean and structure data for analysis

## Data loading and cleaning

### Goal
Load the raw FluNet data and convert it into a clean, analysis-ready weekly dataset.

---

### What I did
- Downloaded influenza surveillance data from WHO FluNet (UK, 2015–2026)
- Saved the file in `data/raw/`
- Wrote a script (`01_download_data.R`) to check that the raw file exists
- Loaded the Excel file using `read_excel()`
- Cleaned column names using `janitor::clean_names()`
- Identified key variables:
  - `iso_year`
  - `iso_week`
  - `spec_processed_nb`
  - `inf_all`
- Renamed variables to simpler names:
  - year, week, tested, positive
- Converted all columns to numeric using `parse_number()`
- Created a proper weekly date variable using ISO week format


---

### Issue encountred
While inspecting the cleaned data, I noticed several problems:

- Multiple rows existed for the same week
- Some rows had:
  - `tested = 0`
  - `positive > 0`
- This resulted in:
  - `positivity = Inf`
- After aggregating weekly totals, I still observed:
  - `positive > tested`
  - positivity values greater than 1

This indicated that:

- The dataset was not structured as one row per week
- The variables `tested` and `positive` were not directly compatible
- The positivity measure was not reliable in this dataset

---

### How I solved it

- Aggregated the data by week:
  - summed `tested` and `positive` for each week
- Recomputed weekly totals correctly
- Identified that positivity was still not meaningful due to inconsistencies in the source data
- Decided to **remove positivity from the analysis**
- Kept:
  - weekly influenza positive detections as the main outcome variable

---

### Key learning

- Real-world epidemiological data is often messy and not analysis-ready
- Variables that seem logically related (tested vs positive) may not be directly comparable
- Always check:
  - duplicate rows
  - impossible values (e.g., positivity > 1)
- Aggregation is often necessary before analysis
- It is important to question the meaning of variables, not just process them mechanically

---

### Outcome

- Created a clean weekly influenza dataset:
  - one row per week
  - consistent time variable
  - reliable outcome variable (positive cases)
- Saved cleaned data to:
  - `data/processed/flu_clean.csv`

---

### Next step

- Perform exploratory analysis:
  - plot influenza cases over time
  - compare epidemic waves across seasons
  - identify growth phases


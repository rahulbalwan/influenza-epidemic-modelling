# influenza-epidemic-modelling

Reproducible epidemic data analysis and transmission modelling of influenza using weekly surveillance data, including growth-rate estimation, season comparison, and compartmental modelling in R.

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
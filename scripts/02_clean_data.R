library(readr)
library(readxl)
library(dplyr)
library(janitor)
library(ISOweek)

# Read in the raw data
df <- read_excel("data/raw/flunet_uk.xlsx")

# Clean column names
df <- df %>%
  clean_names()

# Check columns
print(names(df))

# Select relevant columns and rename them
flu_clean <- df %>% select(iso_year, iso_week, spec_processed_nb, inf_all) %>%
    rename(year = iso_year, week = iso_week, tested = spec_processed_nb, positive = inf_all) %>%
    mutate(year = readr::parse_number(as.character(year)), week = readr::parse_number(as.character(week)), tested = readr::parse_number(as.character(tested)), positive = readr::parse_number(as.character(positive)), positive = readr::parse_number(as.character(positive))) %>%
    mutate(tested = ifelse(is.na(tested), 0, tested), positive = ifelse(is.na(positive), 0, positive)) %>%
    mutate(date = ISOweek2date(paste0(year, "-W", sprintf("%02d", week), "-1"))) %>%
    filter(!is.na(date)) %>%
    group_by(year, week, date) %>%
    summarise(tested = sum(tested), positive = sum(positive), .groups = "drop") %>%
    arrange(date)


# Save the cleaned data
write_csv(flu_clean, "data/processed/flu_clean.csv")

message("Data cleaning complete. Cleaned data saved to data/processed/flu_clean.csv")
message("Rows: ", nrow(flu_clean))


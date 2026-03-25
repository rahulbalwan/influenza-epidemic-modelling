file_path <- "data/raw/flunet_uk.xlsx"

if (!file.exists(file_path)) {
  stop("Raw influenza file not found: data/raw/flunet_uk.xlsx")
}

message("Raw influenza data file found.")
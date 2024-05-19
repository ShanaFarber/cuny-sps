library(tidyverse)

# data can be downloaded from https://ww2.nycourts.gov/pretrial-release-data-33136 (NYC)

# load data
NYC <- read.csv("data/NYC for Web.csv", na.strings = c("NULL", " ", "\\s+", ""))

# change column names to snake_case
names(NYC) <- snakecase::to_snake_case(names(NYC))

###### FILTERING ######

# filter only cases in Kings
brooklyn_county_releases <- NYC |>
  filter(county_name == "Kings")

# filter only those in 2021 and 2022
brooklyn_2021_2022 <- brooklyn_county_releases |>
  filter(arrest_year %in% c(2021, 2022))

# uncomment below to check rows
#nrow(brooklyn_2021_2022)    # 74793

# filter only cases where individual was taken into custody
brooklyn_2021_2022 <- brooklyn_2021_2022 |>
  filter(arrest_type == "Custody")

# filter only cases which were disposed
brooklyn_2021_2022 <- brooklyn_2021_2022 |>
  filter(docket_status == "Disposed")

# filter only those which have information for release decision, were not disposed at arraign, were not remanded
brooklyn_2021_2022 <- brooklyn_2021_2022 |>
  filter(!release_decision_at_arraign %in% c("Disposed at arraign", "Unknown", "Remanded"))

# filter only known rearrest status
brooklyn_2021_2022 <- brooklyn_2021_2022 |>
  filter(rearrest != "Unknown")

# uncomment below to check rows
#nrow(brooklyn_2021_2022)    # 51,008


###### CLEANING ########

# criminal history columns are characters
# convert to numerics
# drop any rows missing criminal history information

# change features to numeric 
brooklyn_2021_2022 <- brooklyn_2021_2022 |>
  mutate(prior_vfo_cnt = as.numeric(str_replace(prior_vfo_cnt, "[+|>]", "")),
         prior_nonvfo_cnt = as.numeric(str_replace(prior_nonvfo_cnt, "[+|>]", "")),
         prior_misd_cnt = as.numeric(str_replace(prior_misd_cnt, "[+|>]", "")),
         pend_vfo = as.numeric(pend_vfo),
         pend_nonvfo = as.numeric(pend_nonvfo),
         pend_misd = as.numeric(pend_misd)) |>
  select(-arr_cycle_id) |>
  drop_na(prior_vfo_cnt, prior_nonvfo_cnt, prior_misd_cnt, pend_vfo, pend_nonvfo, pend_misd) # drop missing criminal history

# uncomment below to check rows
#nrow(brooklyn_2021_2022)    # 51,008

# Save CSV
write.csv(brooklyn_2021_2022, "data/brooklyn_2021_2022.csv", row.names = F)


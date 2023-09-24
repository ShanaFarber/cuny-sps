# load packages
library(tidyverse)
library(dotenv)
library(fredr)

load_dot_env("C:/Users/Shoshana/Documents/CUNY SPS/cuny-sps/DATA_608/Story2/.env")

# Federal Reserve Board (FRED)
# Helpful link for accessing FRED API in R: https://cran.r-project.org/web/packages/fredr/vignettes/fredr.html  

# API key
api_key <- Sys.getenv("FRED_API_KEY")
set_fred_key(api_key)

# cpi values
cpi <- fredr(series_id = "CPIAUCSL",
             observation_start = as.Date("1998-01-01"),
             observation_end = as.Date("2022-12-31")) |>
  select(date, "cpi" = value)

# unemployment rates
unemploy <- fredr(series_id = "UNRATE",
                  observation_start = as.Date("1998-01-01"),
                  observation_end = as.Date("2022-12-31")) |>
  select(date, "unemploy" = value)

# federal fund rates
fed_fund_rate <- fredr(series_id = "DFF",
                       observation_start = as.Date("1998-01-01"),
                       observation_end = as.Date("2022-12-31")) |>
  select(date, "ffr" = value) |>
  separate(date, into = c("year", "month", "day"), sep="-") |>
  group_by(year, month) |>
  summarize("ffr" = mean(ffr)) |>    # cpi and unemploy both monthly - average to just have monthly basis
  mutate(day = "01") |>
  unite(year, month, day, col = "date", sep='-') |>
  mutate(date = as.Date(date))

# create dataframe of all data
data <- cpi |>
  left_join(unemploy, by = "date") |>
  left_join(fed_fund_rate, by = "date")

# find annual averages and calculate annual 
# inflation rate = ((current cpi) - (previous cpi) / previous cpa) * 100
annual_avgs <- data |>
  mutate(year = year(date)) |>
  group_by(year) |>
  summarize(avg_cpi = mean(cpi),
            avg_unemploy = mean(unemploy),
            avg_ffr = mean(ffr)) |>
  mutate(inflation = ((avg_cpi - lag(avg_cpi))/lag(avg_cpi))*100)

# save data
write.csv(data, "C:/Users/Shoshana/Documents/CUNY SPS/cuny-sps/DATA_608/Story2/data.csv", row.names = FALSE)
write.csv(annual_avgs, "C:/Users/Shoshana/Documents/CUNY SPS/cuny-sps/DATA_608/Story2/annual_avg_data.csv", row.names = FALSE)


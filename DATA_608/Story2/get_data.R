# load packages
library(httr)
library(tidyverse)
library(glue)
library(jsonlite)
library(dotenv)
library(fredr)

load_dot_env("C:/Users/Shoshana/Documents/CUNY SPS/cuny-sps/DATA_608/Story2/.env")

# Bureau of Labor Statistics (BLS)
# insert API key
api_key <- Sys.getenv("BLS_API_KEY")

# API URL
url <- "https://api.bls.gov/publicAPI/v2/timeseries/data/"

# CPI and unemployment for last 25 years
# BLS API only allows to call 20 years per query so this has to be done in two stages
# Helpful video for navigating BLS API: https://www.youtube.com/watch?v=118FyvU6OSc 

# 20 years from 1998-2017
payload <- glue('{
  "seriesid":["CUSR0000SA0", "LNS14000000"],
  "startyear":"1998",
  "endyear":"2017",
  "registrationkey":"{{api_key}}"
}', .open="{{", .close="}}")

response <- POST(url,
                 body=payload,
                 content_type("application/json"),
                 encode="json")

x <- content(response, "text") |>
  jsonlite::fromJSON()

cpi_1998_2017 <- x$Results$series$data[[1]] |>
  as_tibble()
unemployment_1998_2017 <- x$Results$series$data[[2]] |>
  as_tibble()

# last 5 years from 2018-2022
payload <- glue('{
  "seriesid":["CUSR0000SA0", "LNS14000000"],
  "startyear":"2018",
  "endyear":"2022",
  "registrationkey":"{{api_key}}"
}', .open="{{", .close="}}")

response <- POST(url,
                 body=payload,
                 content_type("application/json"),
                 encode="json")

x <- content(response, "text") |>
  jsonlite::fromJSON()

cpi_2018_2022 <- x$Results$series$data[[1]] |>
  as_tibble() 
unemployment_2018_2022 <- x$Results$series$data[[2]] |>
  as_tibble() 

# combine 1998-2017 and 2018-2022 dataframes
cpi <- rbind(cpi_2018_2022, cpi_1998_2017) |>
  select(-footnotes) |>
  rename("cpi" = "value")
unemployment <- rbind(unemployment_2018_2022, unemployment_1998_2017) |>
  select(-footnotes) |>
  rename("unemployment" = "value")

cpi_unemployment <- left_join(cpi, unemployment, by=c("year", "period", "periodName"))


# Federal Reserve Board (FRED)
# Helpful link for accessing FRED API in R: https://cran.r-project.org/web/packages/fredr/vignettes/fredr.html  

# API key
api_key <- Sys.getenv("FRED_API_KEY")
set_fred_key(api_key)

fed_fund_rate <- fredr(series_id = "DFF",
                       observation_start = as.Date("1998-01-01"),
                       observation_end = as.Date("2022-12-31"))

fed_fund_cleaned <- fed_fund_rate |>
  select(date, "ffr" = value) |>
  separate(date, into = c("year", "month", "day"), sep="-") |>
  group_by(year, month) |>
  summarize("ffr" = mean(ffr))

periods <- data.frame("periodName" = c("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"),
                      "month" = c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"))

cpi_unemployment_cleaned <- cpi_unemployment |>
  left_join(periods, by = "periodName") |>
  select(-period, -periodName)

data <- cpi_unemployment_cleaned |>
  left_join(fed_fund_cleaned, by = c("year", "month")) |>
  mutate(day = "01") |>
  unite(year, month, day, col = "date", sep = "-") |>
  mutate(date = as.Date(date))

write.csv(data, "C:/Users/Shoshana/Documents/CUNY SPS/cuny-sps/DATA_608/Story2/data.csv", row.names = FALSE)


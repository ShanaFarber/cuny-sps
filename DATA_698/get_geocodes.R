library(tidyverse)
library(tigris)
library(sf)

# info found here: https://rpubs.com/ben_bellman/sf_tigris


############### NY ################

# load data
historic_nypd <- read.csv("data/nypd_arrests_2020_2023.csv", na.strings = "")

# change columns names to snake case
names(historic_nypd) <- snakecase::to_snake_case(names(historic_nypd))

# get sf geometry
historic_nypd <- historic_nypd |> 
  filter((!is.na("longitude")) & (!is.na("latitude"))) |> 
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

historic_nypd <- st_transform(historic_nypd, 4269)  # add geographic information

# get NY census tract information from tigris package and apply sf geographies
ny <- tracts(state = 36)
ny <- st_as_sf(ny)

# spacial join the data
joined_ny <- data.frame(st_join(historic_nypd, ny))

# remove unnecessary columns
nypd_arrests_geoid <- joined_ny |>
  select(-c(x_coord_cd:TRACTCE),-c(NAME:FUNCSTAT), -c(AWATER:INTPTLON))


############### LA #####################

# load data
historic_la <- read.csv("data/la_arrests_2020_2023.csv", na.strings = "")

# change columns names to snake case
names(historic_la) <- snakecase::to_snake_case(names(historic_la))

# get sf geometry
historic_la <- historic_la |> 
  filter((!is.na("lon")) & (!is.na("lat"))) |> 
  st_as_sf(coords = c("lon", "lat"), crs = 4326)

historic_la <- st_transform(historic_la, 4269)  # add geographic information

# get NY census tract information from tigris package and apply sf geographies
la <- tracts(state = 06)
la <- st_as_sf(la)

# spacial join the data
joined_la <- data.frame(st_join(historic_la, la))

# remove unnecessary columns
la_arrests_geoid <- joined_la |>
  select(-c(address:TRACTCE), -c(NAME:FUNCSTAT), -c(AWATER:INTPTLON))

# save as .RData
save(nypd_arrests_geoid, la_arrests_geoid, file = "data/geoid_master.RData")

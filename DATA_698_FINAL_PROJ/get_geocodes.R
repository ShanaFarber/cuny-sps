library(tidyverse)
library(tigris, options(tigris_use_cache = TRUE))
library(sf)

# info found here: https://rpubs.com/ben_bellman/sf_tigris


############### NY ################

# load data
historic_nypd <- read.csv("data/nypd_arrests_2015_2019.csv", na.strings = "")

# change columns names to snake case
names(historic_nypd) <- snakecase::to_snake_case(names(historic_nypd))

# get sf geometry
historic_nypd <- historic_nypd |> 
  filter((!is.na("longitude")) & (!is.na("latitude"))) |> 
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

historic_nypd <- st_transform(historic_nypd, 4269)  # add geographic information


######### TRACTS ##########

# get NY census tract information from tigris package and apply sf geographies
ny_tracts <- tracts(state = 36)
ny_tracts <- st_as_sf(ny_tracts)

# spacial join the data
joined_ny_tracts <- data.frame(st_join(historic_nypd, ny_tracts))

# remove unnecessary columns
nypd_arrests_tracts <- joined_ny_tracts |>
  select(-c(x_coord_cd:TRACTCE),-c(NAME:FUNCSTAT), -c(AWATER:INTPTLON))


########## ZIPS ############

# get zctas for NY
ny_zctas <- zctas(state = 36, year=2010)
ny_zctas <- st_as_sf(ny_zctas)

# spacial join the data
joined_ny_zctas <- data.frame(st_join(historic_nypd, ny_zctas))

# remove unnecessary columns
nypd_arrests_zctas <- joined_ny_zctas |>
  select(-c(x_coord_cd:STATEFP10),-c(GEOID10:PARTFLG10)) |>
  rename("GEOID" = ZCTA5CE10) 

# save as .RData
save(nypd_arrests_tracts, nypd_arrests_zctas, file = "data/nypd_arrests_master.RData")

# save as CSV
write.csv(nypd_arrests_tracts, file="data/nypd_arrests_tracts.csv")
write.csv(nypd_arrests_zctas, file="data/nypd_arrests_zctas")

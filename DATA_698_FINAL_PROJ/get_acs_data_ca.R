library(tidycensus)
library(tigris, options(tigris_use_cache = TRUE))
library(sf)
library(tidyverse)
library(dplyr)

# insert census API key below
# census_api_key("<your_key>", install = TRUE)

readRenviron("~/.Renviron")

census_ca_tracts <- get_acs(geography = "tract",
                            variables = c(total_pop = "B01001_001",
                                          total_male = "B01001_002",
                                          male_18to19 = "B01001_007",
                                          male_20 = "B01001_008",
                                          male_21 = "B01001_009",
                                          male_22to24 = "B01001_010",
                                          male_25to29 = "B01001_011",
                                          male_30to34 = "B01001_012",
                                          male_35to39 = "B01001_013",
                                          male_40to44 = "B01001_014",
                                          male_45to49 = "B01001_015",
                                          male_50to54 = "B01001_016",
                                          male_55to59 = "B01001_017",
                                          male_60to64 = "B01001_018",
                                          male_65to66 = "B01001_019",
                                          male_67to69 = "B01001_020",
                                          male_70to74 = "B01001_021",
                                          male_75to79 = "B01001_022",
                                          male_80to84 = "B01001_023",
                                          male_85_up = "B01001_024",
                                          female_18to19 = "B01001_031",
                                          female_20 = "B01001_032",
                                          female_21 = "B01001_033",
                                          female_22to24 = "B01001_034",
                                          female_25to29 = "B01001_035",
                                          female_30to34 = "B01001_036",
                                          female_35to39 = "B01001_037",
                                          female_40to44 = "B01001_038",
                                          female_45to49 = "B01001_039",
                                          female_50to54 = "B01001_040",
                                          female_55to59 = "B01001_041",
                                          female_60to61 = "B01001_042",
                                          female_62to64 = "B01001_043",
                                          female_64to66 = "B01001_044",
                                          female_67to69 = "B01001_045",
                                          female_70to74 = "B01001_046",
                                          female_75to79 = "B01001_047",
                                          female_80to84 = "B01001_048",
                                          female_85_up = "B01001_049",
                                          total_white = "B01001A_001",
                                          total_non_citizen = "B05001_006",
                                          median_income = "B06011_001",
                                          median_household_income = "B19013_001",
                                          total_families = "B17010_001",
                                          families_below_poverty_income = "B17010_002",
                                          single_father_young_children_under_poverty = "B17010_010",
                                          single_mother_young_children_under_poverty = "B17010_016",
                                          single_father_young_children_above_poverty = "B17010_030",
                                          single_mother_young_children_above_poverty = "B17010_036",
                                          housing_units = "B25002_001",
                                          vacant_houses = "B25002_003",
                                          male_16to64_in_labor_force = "C23002I_004",
                                          male_65_plus_in_labor_force = "C23002I_011",
                                          male_16to64_in_labor_force_unemployed = "C23002I_008",
                                          male_65_plus_in_labor_force_unemployed = "C23002I_013",
                                          female_16to64_in_labor_force = "C23002I_017",
                                          female_65_plus_in_labor_force = "C23002I_024",
                                          female_16to64_in_labor_force_unemployed = "C23002I_021",
                                          female_65_plus_in_labor_force_unemployed = "C23002I_026",
                                          total_commute_to_work = "B08126_001",
                                          total_walk_to_work = "B08126_061",
                                          median_age = "B06002_001",
                                          pop_over_25 = "B06009_001",
                                          less_than_hs_grad = "B06009_002",
                                          hs_ged = "B06009_003",
                                          bs_degree = "B06009_005",
                                          grad_degree = "B06009_006"),
                            state = "CA",
                            survey = "acs5",
                            year = 2019,
                            geometry = TRUE) |>
  transmute(GEOID, NAME, variable, estimate)


############### NY ################

# load data
historic_la <- read.csv("data/la_arrests_data.csv", na.strings = "")

# change columns names to snake case
names(historic_la) <- snakecase::to_snake_case(names(historic_la))

# get sf geometry
historic_la <- historic_la |> 
  filter((!is.na("lon")) & (!is.na("lat"))) |> 
  st_as_sf(coords = c("lon", "lat"), crs = 4326)

historic_la <- st_transform(historic_la, 4269)  # add geographic information


######### TRACTS ##########

# get NY census tract information from tigris package and apply sf geographies
la_tracts <- tracts(state = 06)
la_tracts <- st_as_sf(la_tracts)

# spacial join the data
joined_la_tracts <- data.frame(st_join(historic_la, la_tracts))

# remove unnecessary columns
la_arrests_tracts <- joined_la_tracts 


####### TRACTS #########

# change to wide format
wide_acs <- census_ca_tracts |>
  pivot_wider(names_from = variable, values_from = estimate) 

# feature engineer variables to get totals
ca_feature_engineered_totals_tracts <- wide_acs |>
  transmute(GEOID, 
            NAME, 
            total_pop, 
            total_male,
            total_white,
            total_non_citizen,
            total_minority = total_pop-total_white,
            pop_18to24 = male_18to19+male_20+male_21+male_22to24+female_18to19+female_20+female_21+female_22to24,
            pop_25to44 = male_25to29+male_30to34+male_35to39+male_40to44+female_25to29+female_30to34+female_35to39+female_40to44,
            pop_45to64 = male_45to49+male_50to54+male_55to59+male_60to64+female_45to49+female_50to54+female_55to59+female_60to61+female_62to64,
            pop_65_plus = male_65to66+male_67to69+male_70to74+male_75to79+male_80to84+male_85_up+female_67to69+female_70to74+female_75to79+female_80to84+female_85_up,
            median_age,
            pop_over_25,
            less_than_hs_grad,
            hs_ged,
            bs_degree,
            grad_degree,
            total_families,
            families_below_poverty_income,
            single_parent_home = single_father_young_children_under_poverty+single_father_young_children_above_poverty+single_mother_young_children_under_poverty+single_mother_young_children_above_poverty,
            median_income,
            median_household_income,
            total_commute_to_work,
            total_walk_to_work,
            pop_in_labor_force = male_16to64_in_labor_force+male_65_plus_in_labor_force+female_16to64_in_labor_force+female_65_plus_in_labor_force,
            pop_unemployed = male_16to64_in_labor_force_unemployed+male_65_plus_in_labor_force_unemployed+female_16to64_in_labor_force_unemployed+female_65_plus_in_labor_force_unemployed,
            housing_units,
            vacant_houses)


# divide by totals to get percents
ca_feature_engineered_percent_tracts <- ca_feature_engineered_totals_tracts |>
  transmute(GEOID, 
            NAME,
            total_pop, 
            perc_male = total_male/total_pop,
            perc_minority = total_minority/total_pop,
            perc_non_citizen = total_non_citizen/total_pop,
            perc_18to24 = pop_18to24/total_pop,
            perc_25to44 = pop_25to44/total_pop,
            perc_45to64 = pop_45to64/total_pop,
            perc_65_plus = pop_65_plus/total_pop,
            perc_low_ed = less_than_hs_grad/pop_over_25,
            perc_bs = bs_degree/pop_over_25,
            perc_grad = grad_degree/pop_over_25,
            perc_fam_below_poverty = families_below_poverty_income/total_families,
            perc_single_parent_home = single_parent_home/total_families,
            median_income,
            median_household_income,
            perc_walk_work = total_walk_to_work/total_commute_to_work,
            perc_unemployed = pop_unemployed/pop_in_labor_force,
            perc_vacant = vacant_houses/housing_units)


# aggregate crime from NYPD arrest dataset
la_agg_crime_tracts <- la_arrests_tracts |>
  group_by(GEOID) |>
  summarize(num_crimes = n())

# join crime and census information
# inner join to include only GEOIDs which we have both census information and arrest information
la_data_totals_tracts <- la_agg_crime_tracts |>
  inner_join(ca_feature_engineered_totals_tracts, by="GEOID")

la_data_percent_tracts <- la_agg_crime_tracts |>
  inner_join(ca_feature_engineered_percent_tracts, by="GEOID")

# save as .RData
save(census_ca_tracts, file = "data/ca_acs_master.RData")

library(tidyverse)

# load data
load('C:/Users/Shoshana/Documents/CUNY SPS/cuny-sps/DATA_698/data/ny_acs_master.RData')
load('C:/Users/Shoshana/Documents/CUNY SPS/cuny-sps/DATA_698/data/nypd_arrests_master.RData')


###################### NY #########################

####### TRACTS #########

# change to wide format
wide_acs <- census_ny_tracts |>
  pivot_wider(names_from = variable, values_from = estimate) 

# feature engineer variables to get totals
ny_feature_engineered_totals_tracts <- wide_acs |>
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
ny_feature_engineered_percent_tracts <- ny_feature_engineered_totals_tracts |>
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
nypd_arrests_tracts <- nypd_arrests_tracts |>
  mutate(major_felony_ind = ifelse(str_detect(ofns_desc, "(MURDER|HOMICIDE|MANSLAUGHTER|RAPE|ROBBERY|FELONY ASSAULT|BURGLARY|GRAND LARCENY|GRAND LARCENY OF MOTOR VEHICLE)"), 1, 0),
         drug_crime_ind = ifelse(str_detect(ofns_desc, "(DRUG|CANNIBIS)"), 1, 0),
         property_crime_ind = ifelse(str_detect(ofns_desc, "(THEFT|ROBBERY|BURGLAR|TRESPASS|PROPERTY)"), 1, 0))

nyc_agg_crime_tracts <- nypd_arrests_tracts |>
  group_by(GEOID) |>
  summarize(num_crimes = n(),
            major_felonies = sum(major_felony_ind),
            drug_crimes = sum(drug_crime_ind),
            property_crimes = sum(property_crime_ind)) |>
  mutate_all(~replace(., is.na(.), 0))

# join crime and census information
# inner join to include only GEOIDs which we have both census information and arrest information
nyc_data_totals_tracts <- nyc_agg_crime_tracts |>
  inner_join(ny_feature_engineered_totals_tracts, by="GEOID")

nyc_data_percent_tracts <- nyc_agg_crime_tracts |>
  inner_join(ny_feature_engineered_percent_tracts, by="GEOID")

####### ZCTAS ################

# ACS data
# change to wide format
wide_acs <- census_ny_zctas |>
  pivot_wider(names_from = variable, values_from = estimate) 

# feature engineer variables to get totals
ny_feature_engineered_totals_zctas <- wide_acs |>
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
ny_feature_engineered_percent_zctas <- ny_feature_engineered_totals_zctas |>
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
nypd_arrests_data_zctas <- nypd_arrests_zctas |>
  mutate(major_felony_ind = ifelse(str_detect(ofns_desc, "(MURDER|HOMICIDE|MANSLAUGHTER|RAPE|ROBBERY|FELONY ASSAULT|BURGLARY|GRAND LARCENY|GRAND LARCENY OF MOTOR VEHICLE)"), 1, 0),
         drug_crime_ind = ifelse(str_detect(ofns_desc, "(DRUG|CANNIBIS)"), 1, 0),
         property_crime_ind = ifelse(str_detect(ofns_desc, "(ROBBERY|THEFT|BURGLARY|LARCENY)"), 1, 0))

nyc_agg_crime_zctas <- nypd_arrests_data_zctas |>
  group_by(GEOID) |>
  summarize(num_crimes = n(),
            major_felonies = sum(major_felony_ind),
            drug_crimes = sum(drug_crime_ind),
            property_crimes = sum(property_crime_ind)) |>
  mutate_all(~replace(., is.na(.), 0))

# join crime and census information
nyc_data_totals_zctas <- nyc_agg_crime_zctas |>
  inner_join(ny_feature_engineered_totals_zctas, by="GEOID")

nyc_data_percent_zctas <- nyc_agg_crime_zctas |>
  inner_join(ny_feature_engineered_percent_zctas, by="GEOID")


# save CSVs
save(nyc_data_percent_tracts, nyc_data_percent_zctas, file = "data/census_crime_joined.RData")


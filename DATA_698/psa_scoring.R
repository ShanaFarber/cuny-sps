library(tidyverse)

# load data
brooklyn_2021_2022 <- read.csv("data/brooklyn_2021_2022.csv")

##### Calculate PSA Scores #####

#### NCA Score (New Criminal Offense) ######

#The NCA score takes into account several different factors:
  
#> Age at current arrest (`age_at_arrest`) - 2 points if defendant aged 22 or younger; 0 otherwise
#> Pending charge at arrest (`pend_misd`, `pend_vfo`, `pend_nonvfo`) - 3 points if the defendant has a currently pending charge at the time of arrest; 0 otherwise
#> Prior misdemeanor conviction (`prior_misd`) - 1 point if the defendant has a prior misdemeanor conviction; 0 otherwise
#> Prior felony conviction (`prior_nonvfo`, `prior_vfo`) - 1 point if the defendant has a prior felony conviction; 0 otherwise
#> Prior violent conviction (`prior_vfo`) - 2 points if the defendant has three or more prior violent convictions; 1 point if the defendant has one or two prior violent convictions; 0 otherwise
#> Prior FTA - don't have this info
#> Prior incarceration - don't have this info

nca_scoring <- brooklyn_2021_2022 |>
  mutate(pend_charge = ifelse(pend_vfo+pend_nonvfo+pend_misd > 0, 1, 0)) |>
  mutate(age_at_arrest_score = ifelse(age_at_arrest <= 22, 2, 0),
         pending_charge_score = ifelse(pend_charge == 1, 3, 0),
         prior_misd_score = ifelse(prior_misd_cnt > 0, 1, 0),
         prior_felony_score = ifelse(prior_nonvfo_cnt > 0 | prior_vfo_cnt > 0, 1, 0),
         prior_violent_score = case_when((prior_vfo_cnt == 1 | prior_vfo_cnt == 2) ~ 1,
                                         prior_vfo_cnt >= 3 ~ 2,
                                         TRUE ~ 0),
         nca_score = age_at_arrest_score + pending_charge_score + prior_misd_score + prior_felony_score + prior_violent_score,
         nca_score = case_when((nca_score %in% c(0,1)) ~ 1,
                               (nca_score %in% c(5,6)) ~ 5,
                               (nca_score %in% c(7,8)) ~ 6,
                               TRUE ~ nca_score)) |>
  ) |>
  select(gender, 
         race, 
         age_at_arrest, 
         top_charge_severity_at_arrest, 
         arraign_charge_category, 
         representation_type, 
         release_decision_at_arraign, 
         supervision, 
         c(age_at_arrest_score:nca_score), 
         rearrest)


#### NVCA Score (New Violent Criminal Offense) #####

#> Current violent offense (`current_vfo_ind`) - 2 points if the current offense is violent; 0 otherwise
#> Current violent offense under 20 years old (`current_vfo_ind`, `age_at_arrest`) - 1 point if the current offense is violent and defendant aged 20 years or younger; 0 otherwise
#> Pending charge at time of arrest (`pend_misd`, `pend_vfo`, `pend_nonvfo`) - 1 point if the defendant has a current pending charge at the time of arrest; 0 otherwise
#> Prior conviction (`prior_misd`, `prior_vfo`, `prior_nonvfo`) - 1 point if the defendant has had a prior conviction for a misdemeanor or a felony; 0 otherwise
#> Prior violent conviction (`prior_vfo`) - 2 points if the defendant has three or more prior violent convictions; 1 point if the defendant has one or two prior violent convictions; 0 otherwise

nvca_scoring <- charges |>
  mutate(pend_charge = ifelse(pend_vfo+pend_nonvfo+pend_misd > 0, 1, 0)) |>
  mutate(current_violent_offense_score = ifelse(arraign_charge_category == "Violent", 2, 0),
         current_violent_20_under = ifelse(arraign_charge_category == "Violent" & age_at_arrest <= 20, 1, 0),
         pending_charge_score = ifelse(pend_charge == 1, 1, 0),
         prior_misd_or_felony_score = ifelse(prior_misd_cnt > 0 | prior_nonvfo_cnt > 0 | prior_vfo_cnt > 0, 1, 0),
         prior_violent_score = case_when((prior_vfo_cnt == 1 | prior_vfo_cnt == 2) ~ 1,
                                         prior_vfo_cnt >= 3 ~ 2,
                                         TRUE ~ 0),
         nvca_score = current_violent_offense_score + current_violent_20_under + pending_charge_score + prior_misd_or_felony_score + prior_violent_score,
         nvca_score = case_when((nvca_score %in% c(0,1)) ~ 1,
                                TRUE ~ nvca_score)) |>
  select(gender, 
         race, 
         age_at_arrest, 
         top_charge_severity_at_arrest, 
         arraign_charge_category, 
         representation_type, 
         release_decision_at_arraign, 
         supervision, 
         c(current_violent_offense_score:nvca_score), 
         rearrest)


# Save CSVs
write.csv(nca_scoring, "data/nca_scored.csv", row.names = F)
write.csv(nvca_scoring, "data/nvca_scored.csv", row.names = F)

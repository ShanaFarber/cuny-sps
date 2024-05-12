This repo contains the files for the DATA 698 - Final Capstone Project.

`get_acs_data.R` retrieves census information for New York.

`get_geocodes.R` retreives the geographical information for New York City arrests.

`feature_engineering.R` creates the desired predictive variables from the ACS census data and combines them with aggregate arrests for New York City census tracts.

`predictive_eda_tracts.Rmd` contains the modeling section of this project. 

`get_acs_data_ca.R` retreives the California census data and performs the feature engineering done for the New York dataset.

The California and New York dataset can be downloaded on the respective Open Data websites:

- New York City Open Data: https://data.cityofnewyork.us/Public-Safety/NYPD-Arrests-Data-Historic-/8h9b-rp9u/about_data (filtered for 2015-2019)

- LA City Open Data: https://data.lacity.org/Public-Safety/Arrest-Data-from-2020-to-Present/amvf-fr72
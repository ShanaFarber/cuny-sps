import pandas as pd
from sodapy import Socrata

# Unauthenticated client only works with public data sets. Note 'None'
# in place of application token, and no username or password:
client = Socrata("data.cdc.gov", None)

# Example authenticated client (needed for non-public datasets):
# client = Socrata(data.cdc.gov,
#                  MyAppToken,
#                  username="user@example.com",
#                  password="AFakePassword")

# Firearm-related injury

# First 2000 results, returned as JSON from API / converted to Python list of
# dictionaries by sodapy.
results = client.get("489q-934x", cause_of_death="Firearm-related injury")

# Convert to pandas DataFrame
results_df = pd.DataFrame.from_records(results)

# 12 months ending with quarter
# age-adjusted rates
firearm_death_rates = results_df[(results_df["time_period"] == "12 months ending with quarter") & (results_df["rate_type"] == "Age-adjusted")]
firearm_death_rates

# rates for states - drop all else
#firearm_death_rates.columns
drop_cols = ["time_period", "cause_of_death", "rate_type", "unit", "rate_overall", "rate_65_74"]
drop_cols.extend([x for x in firearm_death_rates.columns if "_age_" in x or "_sex_" in x])
firearm_death_rates = firearm_death_rates.drop(drop_cols,axis=1)

# grab only third quarter 2022 rates - most recent
firearm_death_rates_2022 = firearm_death_rates[firearm_death_rates["year_and_quarter"] == "2022 Q3"]

# pivot table
firearm_death_rates_2022_long = pd.melt(firearm_death_rates_2022, id_vars="year_and_quarter", var_name="state", value_name="deaths_per_100k").drop(["year_and_quarter"],axis=1)
firearm_death_rates_2022_long["state"] = firearm_death_rates_2022_long["state"].apply(lambda x: x.replace("rate_", "")).apply(lambda x: x.replace("_", " ")).apply(lambda x: x.upper())

firearm_death_rates_2022_long.to_csv("firearms-injuries.csv", index=False)
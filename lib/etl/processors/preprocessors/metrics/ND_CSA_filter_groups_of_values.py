#!/usr/bin/env python

import pandas as pd

# using pd.read_excel
df_ACT_State = pd.read_excel(
    "State_Level_Grade11_Mandatory_ACT_Data.xlsx", sheet_name="2018-2019"
)
df_ACT_District = pd.read_excel(
    "District_Level_Grade11_Mandatory_ACT_Data.xlsx",
    sheet_name="2018-2019",
    converters={"Entity_ID": str},
)
df_ACT_School = pd.read_excel(
    "School_Level_Grade11_Mandatory_ACT_Data.xlsx",
    sheet_name="2018-2019",
    converters={"Entity_ID": str, "District_ID": str},
)
df_Grad_State = pd.read_excel("State_Level_Grad_Rate_Data.xlsx", sheet_name="2018-2019")
df_Grad_District = pd.read_excel(
    "District_Level_Grad_Rate_Data.xlsx",
    sheet_name="2018-2019",
    converters={"District_ID": str},
)
df_Grad_School = pd.read_excel(
    "School_Level_Grad_Rate_Data.xlsx",
    sheet_name="2018-2019",
    converters={"Entity_ID": str, "District_ID": str},
)
df_Enrollment_School = pd.read_excel(
    "2020.01.22.xlsx",
    sheet_name="Higher Ed Enrollment",
    converters={"HS_Institution_ID": str},
)

# using pd.read_csv
df_Persistence_School = pd.read_csv(
    "results.csv",
    sep=",",
    dtype={"District": str, "High School": str, "Count": str, "Retention Rate": str},
)

# reading in the crosswalk file and using use .merge to get the ids into the main file
crosswalk_file = pd.read_excel(
    "ND_crosswalk_school_2020_edited.xlsx",
    converters={"state_id": str, "entity_name": str},
)
crosswalked_Persistence_School = df_Persistence_School.merge(
    right=crosswalk_file, how="left", left_on="High School", right_on="entity_name"
)


# drop the unwanted values from the data frames that need it
breakdowns_keep = [
    "All",
    "Asian American",
    "Black",
    "English Learner",
    "Female",
    "Hispanic",
    "IEP (student with disabilities)",
    "Low Income",
    "Male",
    "Native American",
    "Native Hawaiian or Pacific Islander",
    "Two or More Races",
    "White",
]
df_ACT_State = df_ACT_State[df_ACT_State["Subgroup_Desc"].isin(breakdowns_keep)]
df_ACT_State = df_ACT_State[df_ACT_State["Subject"] != "Writing"]
df_ACT_District = df_ACT_District[
    df_ACT_District["Subgroup_Desc"].isin(breakdowns_keep)
]
df_ACT_District = df_ACT_District[df_ACT_District["Subject"] != "Writing"]
df_ACT_District.dropna(subset=["Average_Score"], inplace=True)
df_ACT_School = df_ACT_School[df_ACT_School["Subgroup_Desc"].isin(breakdowns_keep)]
df_ACT_School = df_ACT_School[df_ACT_School["Subject"] != "Writing"]
df_ACT_School.dropna(subset=["Average_Score"], inplace=True)
df_Grad_State = df_Grad_State[df_Grad_State["Subgroup_Desc"].isin(breakdowns_keep)]
df_Grad_State = df_Grad_State[df_Grad_State["Traditional_Graduation_Rate"] != "i"]
df_Grad_District = df_Grad_District[
    df_Grad_District["Subgroup_Desc"].isin(breakdowns_keep)
]
df_Grad_District = df_Grad_District[
    df_Grad_District["Traditional_Graduation_Rate"] != "i"
]
df_Grad_School = df_Grad_School[df_Grad_School["Subgroup_Desc"].isin(breakdowns_keep)]
df_Grad_School = df_Grad_School[df_Grad_School["Traditional_Graduation_Rate"] != "i"]
df_Enrollment_School = df_Enrollment_School[
    df_Enrollment_School["12 vs. 16 Months Out"] == 16
]

# create new csv files
df_ACT_State.to_csv("ACT_State.txt", index=None, sep="\t")
df_ACT_District.to_csv("ACT_District.txt", index=None, sep="\t")
df_ACT_School.to_csv("ACT_School.txt", index=None, sep="\t")
df_Grad_State.to_csv("Grad_State.txt", index=None, sep="\t")
df_Grad_District.to_csv("Grad_District.txt", index=None, sep="\t")
df_Grad_School.to_csv("Grad_School.txt", index=None, sep="\t")
df_Enrollment_School.to_csv("Enrollment_School.txt", index=None, sep="\t")
crosswalked_Persistence_School.to_csv("Persistence_School.txt", index=None, sep="\t")
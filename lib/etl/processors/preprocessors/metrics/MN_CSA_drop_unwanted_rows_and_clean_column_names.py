#!/usr/bin/env python

import pandas as pd


# using read_excel to use the excel files directly and create data frames
df_GradRateState = pd.read_excel(
    "2019 Graduation Indicators.xlsx",
    sheet_name="State",
    header=[3],
    converters={"ID#": str},
)
df_GradRateDistrict = pd.read_excel(
    "2019 Graduation Indicators.xlsx",
    sheet_name="District",
    header=[4],
    converters={"District Number": str, "District Type": str},
)
df_GradRateSchool = pd.read_excel(
    "2019 Graduation Indicators.xlsx",
    sheet_name="School",
    header=[4],
    converters={"District Number": str, "District Type": str, "School Number": str},
)
df_ACTData = pd.read_excel(
    "Minnesota 2019 Public Schools Graduating Class 5 Year Trends.xlsx",
    converters={"ACT Dist Code": str, "ACT HS Code": str},
)
df_EnrollmentData = pd.read_excel(
    "SLEDS_HSGrad_Enrollment_extracted20200226.xlsx",
    sheet_name="Enrollment",
    converters={"District Type": str, "District Number": str, "School Number": str},
)
df_PersistenceData = pd.read_excel(
    "SLEDS_HSGrad_Completing_College_extracted20200226.xlsx",
    converters={"District Type": str, "District Number": str, "School Number": str},
)
df_RemediationData = pd.read_excel(
    "SLEDS_HSGrad_Developmental_Education_extracted20200226.xlsx",
    converters={"District Type": str, "District Number": str, "School Number": str},
)

# transpose for data frames that need it
transposed_ACTData = pd.melt(
    df_ACTData,
    id_vars=[
        "Analysis Level",
        "District Name",
        "ACT Dist Code",
        "HS Name",
        "ACT HS Code",
        "Grad Year",
        "N",
    ],
    value_vars=[
        "Avg Eng",
        "Avg Math",
        "Avg Reading",
        "Avg Sci",
        "Avg Comp",
        "CRB % Eng",
        "CRB % Math",
        "CRB % Reading",
        "CRB % Sci",
        "CRB % All Four",
    ],
)

# crosswalk to get state ids into the frames that need it
crosswalk_file = pd.read_excel(
    "ACT and MDE IDs_2020_08_27.xlsx",
    converters={"dist_num": str, "dist_tye": str, "sch_num": str, "ACTID": str},
)
crosswalked_ACT_District = transposed_ACTData.merge(
    right=crosswalk_file, how="left", left_on="ACT Dist Code", right_on="ACTID"
)
crosswalked_ACT_School = crosswalked_ACT_District.merge(
    right=crosswalk_file, how="left", left_on="ACT HS Code", right_on="ACTID"
)


# drop the unwanted values from the data frames that need it
df_GradRateState.dropna(subset=["Four \nYear Percent"], inplace=True)
df_GradRateState = df_GradRateState[
    df_GradRateState["Ending\nStatus"] == "Graduate"
]  # keep only Graduate rows

df_GradRateDistrict.dropna(subset=["Four \nYear Percent"], inplace=True)
df_GradRateDistrict = df_GradRateDistrict[
    df_GradRateDistrict["Ending\nStatus"] == "Graduate"
]  # keep only Graduate rows

df_GradRateSchool.dropna(subset=["Four \nYear Percent"], inplace=True)
df_GradRateSchool = df_GradRateSchool[
    df_GradRateSchool["Ending\nStatus"] == "Graduate"
]  # keep only Graduate rows

crosswalked_ACT_School.dropna(subset=["value"], inplace=True)
crosswalked_ACT_School = crosswalked_ACT_School[
    crosswalked_ACT_School.value != "."
]  # get rid of values of '.'
crosswalked_ACT_School = crosswalked_ACT_School[
    crosswalked_ACT_School["Grad Year"] == 2019
]  # keep only 2019 year rows

df_EnrollmentData.dropna(
    subset=["HS Grads - Percent Enroll in Fall In MN"], inplace=True
)
df_EnrollmentData = df_EnrollmentData[
    df_EnrollmentData["Year"] == 2018
]  # keep only 2018 year rows
df_EnrollmentData = df_EnrollmentData[
    df_EnrollmentData["Report_Level"] != "Economic Development Region"
]  # get rid of unwanted entity type

df_PersistenceData = df_PersistenceData[
    df_PersistenceData["HS Graduates Starting College - Year 1"] != 0
]  # get rid of rows with cohort count of 0 (because value column 0s not consistent)
df_PersistenceData = df_PersistenceData[
    df_PersistenceData["Year"] == 2017
]  # keep only 2017 year rows
df_PersistenceData = df_PersistenceData[
    df_PersistenceData["Report_Level"] != "Economic Development Region"
]  # get rid of unwanted entity type

df_RemediationData.dropna(
    subset=["Pct of HS Grads Enrolled in Dev Ed in First or Second Fall Term"],
    inplace=True,
)
df_RemediationData = df_RemediationData[
    df_RemediationData["Year"] == 2018
]  # keep only 2018 year rows
df_RemediationData = df_RemediationData[
    df_RemediationData["Report_Level"] != "Economic Development Region"
]  # get rid of unwanted entity type


# Clean up the new lines in columm names in files that need it before creating the .txt files
df_GradRateState.columns = df_GradRateState.columns.str.replace("\n", " ")
df_GradRateDistrict.columns = df_GradRateDistrict.columns.str.replace("\n", " ")
df_GradRateSchool.columns = df_GradRateSchool.columns.str.replace("\n", " ")

# # convert the data frames to .txt files
df_GradRateState.to_csv("Grad_Rate_State.txt", index=None, sep="\t")
df_GradRateDistrict.to_csv("Grad_Rate_District.txt", index=None, sep="\t")
df_GradRateSchool.to_csv("Grad_Rate_School.txt", index=None, sep="\t")
crosswalked_ACT_School.to_csv("ACT_Data.txt", index=None, sep="\t")
df_EnrollmentData.to_csv("Enrollment.txt", index=None, sep="\t")
df_PersistenceData.to_csv("Persistence.txt", index=None, sep="\t")
df_RemediationData.to_csv("Remediation.txt", index=None, sep="\t")

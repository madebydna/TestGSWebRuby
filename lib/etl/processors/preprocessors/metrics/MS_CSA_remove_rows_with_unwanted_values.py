#!/usr/bin/env python

import pandas as pd


# using read_excel to use the excel files directly and create data frames
df_GradRateState = pd.read_csv(
    "tabula-grad-dropout-rates-2019-report.tsv", delimiter="\t"
)
df_GradRateDistrict = pd.read_excel(
    "2019_accountability_media_file_9.17.19 (5).xlsx",
    sheet_name="Districts",
    converters={"ID#": str},
)
df_GradRateT1000 = pd.read_excel(
    "2019_accountability_media_file_9.17.19 (5).xlsx",
    sheet_name="T 1000 Point Schools",
    converters={"ID#": str},
)
df_GradRateNT1000 = pd.read_excel(
    "2019_accountability_media_file_9.17.19 (5).xlsx",
    sheet_name="NT 1000 Point Schools",
    converters={"ID#": str},
)
df_ACTData = pd.read_excel(
    "MDE Great Schools ACT data.xlsx",
    converters={"SCHOOL UNIQUE ID": str, "DISTRICT_NUMBER": str, "SCHOOL_NUMBER": str},
)
df_CollegeData = pd.read_excel(
    "MDE Great Schools Postsecondary data (1).xlsx",
    converters={"Unique School ID": str, "District Number": str, "School Number": str},
)


# drop the blank and unwanted values from the data frames that need it and transpose for data frames that need it
df_GradRateDistrict.dropna(subset=["Graduation Rate"], inplace=True)
df_GradRateDistrict = df_GradRateDistrict[
    ~df_GradRateDistrict["Graduation Rate"].astype(str).str.contains("ǂ")
]

transposed_ACTData = pd.melt(
    df_ACTData,
    id_vars=[
        "SCHOOL UNIQUE ID",
        "DISTRICT_NUMBER",
        "District Name",
        "SCHOOL_NUMBER",
        "School Name",
        "SUBGROUP",
    ],
    value_vars=[
        "Average ACT Score (18-19 Statewide Admin)",
        "ACT Participation (18-19 Statewide Admin)",
    ],
)
transposed_ACTData = transposed_ACTData[
    ~transposed_ACTData["value"].astype(str).str.contains("<10")
]

transposed_CollegeData = pd.melt(
    df_CollegeData,
    id_vars=[
        "Category",
        "Unique School ID",
        "District Number",
        "District Name",
        "School Number",
        "School Name",
        "Sub-Group",
    ],
    value_vars=[
        "Percent Enrolling in MS Public Postsecondary",
        "Percent Taking Remedial Courses",
        "Percent Retained ",
    ],
)
transposed_CollegeData = transposed_CollegeData[
    ~transposed_CollegeData["value"].astype(str).str.contains("<10")
]


# convert the data frames to .txt files
df_GradRateState.to_csv("GraduationRateState.txt", index=None, sep="\t")
df_GradRateDistrict.to_csv("GraduationRateDistrict.txt", index=None, sep="\t")
df_GradRateT1000.to_csv("GraduationRateSchool1.txt", index=None, sep="\t")
df_GradRateNT1000.to_csv("GraduationRateSchool2.txt", index=None, sep="\t")
transposed_ACTData.to_csv("ACTData.txt", index=None, sep="\t")
transposed_CollegeData.to_csv("CollegeData.txt", index=None, sep="\t")

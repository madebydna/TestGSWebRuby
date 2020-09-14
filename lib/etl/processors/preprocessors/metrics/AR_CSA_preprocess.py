#!/usr/bin/env python

import pandas as pd


# using read_excel to use the excel files directly and create data frames
df_ACT_SAT_District = pd.read_excel(
    "ACT_SAT Averages District Level.xlsx", header=[1], converters={"District LEA": str}
)
df_ACT_SAT_School = pd.read_excel(
    "ACT_SAT Averages School Level.xlsx",
    header=[1],
    converters={"District LEA": str, "School LEA": str},
)
df_Grad_Rate_District = pd.read_excel(
    "Cohort Graduation Rate 4th Year with ACT_SAT Averages District Level 2018-2019 Update.xlsx",
    header=[1],
    converters={"District LEA": str},
)
df_Grad_Rate_School = pd.read_excel(
    "Cohort Graduation Rate 4th Year with ACT_SAT Averages School Level 2018-2019 Update.xlsx",
    header=[1],
    converters={"District LEA": str, "School LEA": str},
)
df_Enrollment_District = pd.read_excel(
    "College Going Rate_District_Level_ 2018-2019.xlsx", converters={"LEA": str}
)
df_Enrollment_School = pd.read_excel(
    "College Going Rate_School Level_ 2018-2019.xlsx", converters={"LEA": str}
)
df_Remediation_State = pd.read_excel("Remediation Rates_State Level 2017-2018.xlsx")
df_Remediation_District = pd.read_excel(
    "Remediation Rates_District Level 2017-2018.xlsx", converters={"District LEA": str}
)
df_Remediation_School = pd.read_excel(
    "Remediation Rates_School Level 2017-2018.xlsx",
    converters={"District LEA": str, "School LEA": str},
)


# drop the rows where "District Decription" is blank
df_ACT_SAT_District.dropna(subset=["District Decription"], inplace=True)
df_ACT_SAT_School.dropna(subset=["District Decription"], inplace=True)
df_Grad_Rate_District.dropna(subset=["District Decription"], inplace=True)
df_Grad_Rate_School.dropna(subset=["District Decription"], inplace=True)


# transpose for data frames that need it
transposed_ACT_SAT_District = pd.melt(
    df_ACT_SAT_District,
    id_vars=["District LEA", "District Decription"],
    value_vars=[
        "Percent who Took ACT",
        "ACT Average Composite Score",
        "ACT Average English Scale Score",
        "ACT Average Scale Score Mathematics",
        "ACT Average Scale Score  Reading",
        "ACT Average Scale Score  Science",
        "Percent Who Took SAT",
        "SAT Average Total Score",
        "SAT Average Math Score",
        "SAT Average Reading Score",
    ],
)

transposed_ACT_SAT_School = pd.melt(
    df_ACT_SAT_School,
    id_vars=["District LEA", "District Decription", "School LEA", "School Description"],
    value_vars=[
        "Percent who Took ACT",
        "ACT Average Composite Score",
        "ACT Average English Scale Score",
        "ACT Average Scale Score Mathematics",
        "ACT Average Scale Score  Reading",
        "ACT Average Scale Score  Science",
        "Percent Who Took SAT",
        "SAT Average Total Score",
        "SAT Average Math Score",
        "SAT Average Reading Score",
    ],
)

transposed_Grad_Rate_District = pd.melt(
    df_Grad_Rate_District,
    id_vars=["District LEA", "District Decription"],
    value_vars=[
        "Overall Grad Rate",
        "Hispanic Grad Rate",
        "Native American Grad Rate",
        "Asian Grad Rate",
        "African American Grad Rate",
        "Hawaiian/Pacific Islander Grad Rate",
        "Caucasian Grad Rate",
        "Two or More Grad Rate",
        "Economic Disadvantage Grad Rate",
        "SPED Grad Rate",
        "LEP Grad Rate",
    ],
)

transposed_Grad_Rate_School = pd.melt(
    df_Grad_Rate_School,
    id_vars=["District LEA", "District Decription", "School LEA", "School Description"],
    value_vars=[
        "Overall Grad Rate",
        "Hispanic Grad Rate",
        "Native American Grad Rate",
        "Asian Grad Rate",
        "African American Grad Rate",
        "Hawaiian/Pacific Islander Grad Rate",
        "Caucasian Grad Rate",
        "Two or More Grad Rate",
        "Economic Disadvantage Grad Rate",
        "SPED Grad Rate",
        "ELL Grad Rate",
    ],
)

transposed_Enrollment_District = pd.melt(
    df_Enrollment_District,
    id_vars=["LEA", "District Name"],
    value_vars=[
        "College Going Rate All Students ",
        " College Going Rate Black/African American",
        " College Going Rate Economically Disadvantaged",
        " College Going Rate Hispanic/Latino",
        " College Going Rate LEP",
        " College Going Rate SPED",
        " College Going Rate White",
    ],
)

transposed_Enrollment_School = pd.melt(
    df_Enrollment_School,
    id_vars=["District LEA", "District Decription", "LEA", "School Name"],
    value_vars=[
        "College Going Rate All Students ",
        " College Going Rate Black/African American",
        " College Going Rate Economically Disadvantaged",
        " College Going Rate Hispanic/Latino",
        " College Going Rate LEP",
        " College Going Rate SPED",
        " College Going Rate White",
    ],
)


# drop blank values (after transposing for the ones that needed it)
transposed_ACT_SAT_School.dropna(subset=["value"], inplace=True)
transposed_ACT_SAT_District.dropna(subset=["value"], inplace=True)
transposed_Grad_Rate_District.dropna(subset=["value"], inplace=True)
transposed_Grad_Rate_School.dropna(subset=["value"], inplace=True)
transposed_Enrollment_District.dropna(subset=["value"], inplace=True)
transposed_Enrollment_School.dropna(subset=["value"], inplace=True)
df_Remediation_District.dropna(subset=["College Remediation Rate"], inplace=True)
df_Remediation_School.dropna(subset=[" Remediation Rates"], inplace=True)


# convert the data frames to .txt files
transposed_ACT_SAT_District.to_csv("ACT_SAT_District.txt", index=None, sep="\t")
transposed_ACT_SAT_School.to_csv("ACT_SAT_School.txt", index=None, sep="\t")
transposed_Grad_Rate_District.to_csv("Grad_Rate_District.txt", index=None, sep="\t")
transposed_Grad_Rate_School.to_csv("Grad_Rate_School.txt", index=None, sep="\t")
transposed_Enrollment_District.to_csv("Enrollment_District.txt", index=None, sep="\t")
transposed_Enrollment_School.to_csv("Enrollment_School.txt", index=None, sep="\t")
df_Remediation_State.to_csv("Remediation_State.txt", index=None, sep="\t")
df_Remediation_District.to_csv("Remediation_District.txt", index=None, sep="\t")
df_Remediation_School.to_csv("Remediation_School.txt", index=None, sep="\t")

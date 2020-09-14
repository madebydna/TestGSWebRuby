#!/usr/bin/env python

import pandas as pd


# using read_excel to use the excel files directly and create data frames
df_ACTPerfState = pd.read_excel("MT_ACTPerf_state.xlsx")
df_ACTPerfDistrictSchool = pd.read_excel(
    "MT_ACTPerf_districtschool.xlsx", converters={"district_id": str, "school_id": str}
)
df_GradRateState = pd.read_excel("MT_grad_state.xlsx")
df_GradRateDistrictSchool = pd.read_excel(
    "MT_grad_districtschool.xlsx", converters={"district_id": str, "school_id": str}
)
df_EnrollRemediationState = pd.read_excel("MT_PSEnrollRemediation_state.xlsx")
df_EnrollRemediationDistrictSchool = pd.read_excel(
    "MT_PSEnrollRemediation_districtschool.xlsx"
)


# crosswalk to get state ids into the frames that need it
district_crosswalk_file = pd.read_excel(
    "MT_crosswalk_district_2020.xlsx", converters={"state_id": str}
)
school_crosswalk_file = pd.read_excel(
    "MT_crosswalk_school_2020.xlsx", converters={"state_id": str}
)

school_merged_EnrollRemediationDistrictSchool = (
    df_EnrollRemediationDistrictSchool.merge(
        right=school_crosswalk_file,
        how="left",
        left_on="school_name",
        right_on="entity_name",
    )
)
district_merged_EnrollRemediationDistrictSchool = (
    school_merged_EnrollRemediationDistrictSchool.merge(
        right=district_crosswalk_file,
        how="left",
        left_on="district_name",
        right_on="entity_name",
    )
)


# # transpose for data frames that need it
transposed_EnrollRemediationState = pd.melt(
    df_EnrollRemediationState,
    id_vars=[
        "hs_senior_year",
        "hs_grads",
        "ps_enrollees",
        "remed_enrollees",
        "breakdown",
    ],
    value_vars=["ps_enroll_rate", "remed_enroll_rate"],
)

transposed_EnrollRemediationDistrictSchool = pd.melt(
    district_merged_EnrollRemediationDistrictSchool,
    id_vars=[
        "hs_senior_year",
        "district_name",
        "school_name",
        "hs_grads",
        "ps_enrollees",
        "remed_enrolees",
        "breakdown",
        "entity_level",
        "entity_name_x",
        "state_id_x",
        "entity_name_y",
        "state_id_y",
    ],
    value_vars=["ps_enroll_rate", "remed_enroll_rate"],
)


# drop the unwanted values from the data frames that need it
df_ACTPerfDistrictSchool = df_ACTPerfDistrictSchool[
    ~df_ACTPerfDistrictSchool["value"].astype(str).str.contains("\*")
]
df_GradRateDistrictSchool = df_GradRateDistrictSchool[
    ~df_GradRateDistrictSchool["value"].astype(str).str.contains("\*")
]
transposed_EnrollRemediationState = transposed_EnrollRemediationState[
    ~transposed_EnrollRemediationState["value"].astype(str).str.contains("\*")
]
transposed_EnrollRemediationDistrictSchool = transposed_EnrollRemediationDistrictSchool[
    ~transposed_EnrollRemediationDistrictSchool["value"].astype(str).str.contains("\*")
]


# convert the data frames to .txt files
df_ACTPerfState.to_csv("ACT_Perf_State.txt", index=None, sep="\t")
df_ACTPerfDistrictSchool.to_csv("ACT_Perf_District_School.txt", index=None, sep="\t")
df_GradRateState.to_csv("Grad_Rate_State.txt", index=None, sep="\t")
df_GradRateDistrictSchool.to_csv("Grad_Rate_District_School.txt", index=None, sep="\t")
transposed_EnrollRemediationState.to_csv(
    "Enroll_Remediation_State.txt", index=None, sep="\t"
)
transposed_EnrollRemediationDistrictSchool.to_csv(
    "Enroll_Remediation_District_School.txt", index=None, sep="\t"
)

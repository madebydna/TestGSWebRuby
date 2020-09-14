#!/usr/bin/env python

import pandas as pd

# using read_excel to use the excel files directly and create data frames
df_GradRateFile = pd.read_excel(
    "GRADUATION_RATE.xlsx",
    sheet_name="DATA",
    converters={"CNTYNO": str, "DIST_NUMBER": str, "STATE_SCH_ID": str},
)
df_CollegeAdmissionExamFile = pd.read_excel(
    "COLLEGE_ADMISSIONS_EXAM.xlsx",
    sheet_name="DATA",
    converters={"CNTYNO": str, "DIST_NUMBER": str, "STATE_SCH_ID": str},
)
df_KYCSADataCollegeEnrollment = pd.read_excel(
    "FINAL - Kentucky College Success Awards Data - 2020.xlsx",
    sheet_name="College_Enroll",
    converters={"Dist_Number": str, "Sch_Cd": str},
)
df_KYCSADataCollegePerformance = pd.read_excel(
    "FINAL - Kentucky College Success Awards Data - 2020.xlsx",
    sheet_name="College_Performance",
    converters={"Dist_Number": str, "Sch_Cd": str},
)


# Crosswalking to get proper state_ids into the files that need them
school_crosswalk_file = pd.read_csv("ky_state_id_map_school.txt", delimiter="\t")
district_crosswalk_file = pd.read_csv("ky_state_id_map_district.txt", delimiter="\t")

school_merged_College_Enrollment_Data = df_KYCSADataCollegeEnrollment.merge(
    right=school_crosswalk_file, how="left", left_on="Sch_Cd", right_on="school_code"
)
district_merged_College_Enrollment_Data = school_merged_College_Enrollment_Data.merge(
    right=district_crosswalk_file,
    how="left",
    left_on="Dist_Number",
    right_on="district_code",
)

school_merged_College_Performance_Data = df_KYCSADataCollegePerformance.merge(
    right=school_crosswalk_file, how="left", left_on="Sch_Cd", right_on="school_code"
)
district_merged_College_Performance_Data = school_merged_College_Performance_Data.merge(
    right=district_crosswalk_file,
    how="left",
    left_on="Dist_Number",
    right_on="district_code",
)


# transpose for files that need it and drop the blank values from the data frames that need it
df_GradRateFile.dropna(subset=["GRADRATE4YR"], inplace=True)

transposed_CollegeAdmissionExamFile = pd.melt(
    df_CollegeAdmissionExamFile,
    id_vars=[
        "CNTYNO",
        "DIST_NUMBER",
        "DIST_NAME",
        "SCH_NUMBER",
        "SCH_NAME",
        "STATE_SCH_ID",
        "NCESID",
        "DEMOGRAPHIC",
        "SUPPRESSEDBENCH",
        "TESTED_BENCH",
    ],
    value_vars=["AVG_ENG", "AVG_RD", "AVG_MA", "AVG_SC", "AVG_COMP"],
)
transposed_CollegeAdmissionExamFile.dropna(subset=["value"], inplace=True)

district_merged_College_Performance_Data.dropna(
    subset=["Percent_Grads_Persisting_Yr2"], inplace=True
)


# convert the data frames to .txt files
df_GradRateFile.to_csv("GraduationRate.txt", index=None, sep="\t")
transposed_CollegeAdmissionExamFile.to_csv(
    "CollegeAdmissionExam.txt", index=None, sep="\t"
)
district_merged_College_Enrollment_Data.to_csv(
    "KYCSADataCollegeEnrollment.txt", index=None, sep="\t"
)
district_merged_College_Performance_Data.to_csv(
    "KYCSADataCollegePerformance.txt", index=None, sep="\t"
)

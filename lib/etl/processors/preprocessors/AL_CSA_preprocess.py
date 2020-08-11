#!/usr/bin/env python

import pandas as pd


# using read_excel to use the excel files directly and create data frames
df_ACTCollegeReady = pd.read_excel("2017-2018 College and Career Readiness Rate-edited2.xlsx",converters={'System Code':str,'School Code':str})
df_GradRate = pd.read_excel("2017-2018 Graduation Rate-edited2.xlsx",converters={'System Code':str,'School Code':str})
df_CollegeEnrollment = pd.read_excel("tabula-2017-2018 National Student Clearinghouse, College Going Rate Report-edited2.xlsx")
df_CollegeRemediation = pd.read_excel("tabula-Alabama remediation-edited2.xlsx",converters={'state_id':str})


# Crosswalking to get proper state_ids into the data frames that need them
school_crosswalk_file = pd.read_excel("AL_crosswalk_school_2020.xlsx")
district_crosswalk_file = pd.read_excel("AL_crosswalk_district_2020.xlsx")

school_merged_CollegeEnrollment = df_CollegeEnrollment.merge(right=school_crosswalk_file, how='left', left_on='entity_name', right_on='entity_name')
district_merged_CollegeEnrollment = school_merged_CollegeEnrollment.merge(right=district_crosswalk_file, how='left', left_on='entity_name', right_on='entity_name')


# drop the blank values from the data frames that need it and transpose for data frames that need it
df_ACTCollegeReady.dropna(subset = ["act_percent_cr"], inplace=True)
df_GradRate.dropna(subset = ["grad_rate"], inplace=True)

transposed_CollegeEnrollment = pd.melt(district_merged_CollegeEnrollment, 
									id_vars = ["entity_name","entity_level","cohort_count_nocommas","state_id_x","state_id_y"],
									value_vars = ["non_enroll_rate","2yr_enroll_rate","4yr_enroll_rate"])

transposed_CollegeRemediation = pd.melt(df_CollegeRemediation, 
									id_vars = ["state_id","school_name", "cohort_count_nocommas"],
									value_vars = ["math_remed_rate", "english_remed_rate", "composite_remed_rate", "any_remed_rate"])


# convert the data frames to .txt files
df_ACTCollegeReady.to_csv("ACTCollegeReady.txt",index=None,sep='\t')
df_GradRate.to_csv("GraduationRate.txt",index=None,sep='\t')
transposed_CollegeEnrollment.to_csv("CollegeEnrollment.txt",index=None,sep='\t')
transposed_CollegeRemediation.to_csv("CollegeRemediation.txt",index=None,sep='\t')



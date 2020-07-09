#!/usr/bin/env python

import pandas as pd

# using read_excel to use the excel files directly
raw_CCRI_Data = pd.read_excel("CCRI_Data_2016-2017-2018-Public.xlsx",sheet_name='CCRI-2016-2017-2018')
raw_MasterDataFile = pd.read_excel("2018-19MasterDataFile20191104Rev.xls",sheet_name='School Data 2019')


# Crosswalking to get proper state_ids into the files
crosswalk_file = pd.read_csv("hi_state_id_map.txt",delimiter='\t')

merged_CCRI_Data = raw_CCRI_Data.merge(right=crosswalk_file, how='left', left_on='SchCode', right_on='bb_state_id')
merged_MasterDataFile = raw_MasterDataFile.merge(right=crosswalk_file, how='left', left_on='School ID', right_on='bb_state_id')


# Transposing and selecting the columns needed
transposed_CCRI_Data = pd.melt(merged_CCRI_Data, 
								id_vars=["GradYr","SchCode","state_id","name","Completers","NSC_Fall_Count","UH_Fall"],
							value_vars=["ACT_Taken_Pct","NSC_Persist_Pct","UH_Math_RemDev_Pct","UH_Eng_RemDev_Pct"])

transposed_MasterDataFile = pd.melt(merged_MasterDataFile, 
								id_vars=["Year","state_id","name","School Type for Strive HI",
									"Subgroup Description"],
							value_vars=["Graduation Rate (%)","College Enrollment Rate (%)"])


transposed_CCRI_Data.to_csv("transposed_CCRI_Data.txt",index=None,sep='\t')
transposed_MasterDataFile.to_csv("transposed_MasterDataFile.txt",index=None,sep='\t')







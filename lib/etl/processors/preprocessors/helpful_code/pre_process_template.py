#!/usr/bin/env python

# Template for pre-processing files 

import pandas as pd

# For Excel files, use pd.read_excel to read in
example_data_frame = pd.read_excel("PUT EXCEL FILE NAME HERE",sheet_name="SHEET NAME HERE",header=[INDEX OF THE HEADER ROW IF IT IS NOT FIRST ROW],converters={'COLUMN NAME':str})

# For tab separated txt or csv files, use pd.read_csv to read in
example_data_frame = pd.read_csv("PUT FILE NAME HERE",
					sep='\t', 
					dtype={ 
						"COLUMN NAME": str,
						"ANOTHER COLUMN NAME": str,
						"YET ANOTHER COLUMN NAME": str,
					})


# If you want file to be transposed when doing your qa, use pd.melt
example_transposed_data_frame = pd.melt(example_data_frame, id_vars=["COLUMN NAME NOT TRANSPOSING","ANOTHER COLUMN NAME NOT TRANSPOSING"],
							                      value_vars=["COLUMN NAME TRANSPOSING","ANOTHER COLUMN NAME TRANSPOSING"])


# If you want to crosswalk to get state ids into your file, read in the crosswalk file like you did with the other files and then use .merge 
crosswalk_file = pd.read_excel("NAME OF CROSSWALK FILE HERE",converters={'COLUMN NAME':str,'ANOTHER COLUMN NAME':str})
# Get the districts and schools in there, showing here one at a time since they can use different columns to crosswalk, but this may vary
example_crosswalked_district = example_transposed_data_frame.merge(right=crosswalk_file, how='left', left_on='COLUMN NAME IN MAIN FILE', right_on='COLUMN NAME IN CROSSWALK FILE')
example_crosswalked_school = example_crosswalked_district.merge(right=crosswalk_file, how='left', left_on='COLUMN NAME IN MAIN FILE', right_on='COLUMN NAME IN CROSSWALK FILE')  

# drop the unwanted values from the data frames that need it
example_crosswalked_school.dropna(subset = ["COLUMN NAME"], inplace=True) # this drops rows where value in the column you specify is blank
example_crosswalked_school = example_crosswalked_school[example_crosswalked_school["COLUMN NAME"] == "VALUE YOU WANT TO KEEP"] # this keeps rows with the value you want
example_crosswalked_school = example_crosswalked_school[example_crosswalked_school.value != "VALUE YOU DO NOT WANT TO KEEP"] # this keeps all rows besides the value you don't want

# Clean up the new lines in columm names in files that need it before creating the .txt files (can also do this earlier in process if easier)
example_crosswalked_school.columns = example_crosswalked_school.columns.str.replace("\n"," ")

# create a new csv file that you will use
example_crosswalked_school.to_csv("NAME OF NEW FILE",index=None,sep='\t')




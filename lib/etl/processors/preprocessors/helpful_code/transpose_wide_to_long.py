#!/usr/bin/env python

import pandas as pd

# using pandas read_csv, melt, and to_csv functions
# read_csv takes: name of file (mine was in same directory), separator (tabs in this case), type of data for each column that you want (strings in this case)
# melt takes: variable representing the file, list of columns that don't need to be transposed, then list of columns that do need to be transposed
# to_csv takes: name you want new file to have, index=None will drop the index as it's not needed, and separator (tabs in this case)

# dealing with cohort1819.txt file
cohort1819_df = pd.read_csv("cohort1819.txt",
					sep='\t',
					dtype={
						"AcademicYear": str,
						"AggregateLevel": str,
						"CountyCode": str,
						"DistrictCode": str,
						"SchoolCode": str,
						"CountyName": str,
						"DistrictName": str,
						"SchoolName": str,
						"CharterSchool": str,
						"DASS": str,
						"ReportingCategory": str,
						"CohortStudents": str,
						"Regular HS Diploma Graduates (Count)": str,
						"Met UC/CSU Grad Req's (Rate)": str
					})
 
transposed_cohort1819_df = pd.melt(cohort1819_df, id_vars=["AcademicYear","AggregateLevel","CountyCode","DistrictCode","SchoolCode","CountyName",
									"DistrictName","SchoolName","CharterSchool","DASS","ReportingCategory","CohortStudents",
									"Regular HS Diploma Graduates (Count)"],
							value_vars=["Regular HS Diploma Graduates (Rate)","Met UC/CSU Grad Req's (Rate)"])

transposed_cohort1819_df.to_csv("transposed_cohort1819.txt",index=None,sep='\t')

# dealing with sat19.txt file
sat19_df = pd.read_csv("sat19.txt",
					sep='\t',
					dtype={
						"CDS": str,
						"CDCode": str,
						"RType": str,
						"SName": str,
						"DName": str,
						"NumTSTTakr12": str,
						"PctERWBenchmark12": str,
						"PctMathBenchmark12": str,
						"NumTSTTakr11": str,
						"PctERWBenchmark11": str,
						"PctMathBenchmark11": str,
						"PctBothBenchmark12": str,
						"PctBothBenchmark11": str
					})
 
transposed_sat19_df = pd.melt(sat19_df, id_vars=["CDS","CDCode","RType","SName","DName","NumTSTTakr12","NumTSTTakr11"],
							value_vars=["PctERWBenchmark12","PctMathBenchmark12","PctERWBenchmark11","PctMathBenchmark11","PctBothBenchmark12","PctBothBenchmark11"])

transposed_sat19_df.to_csv("transposed_sat19.txt",index=None,sep='\t')


# dealing with act19.txt file
act19_df = pd.read_csv("act19.txt",
					sep='\t',
					dtype={
						"CDS": str,
						"CDCode": str,
						"RType": str,
						"SName": str,
						"DName": str,
						"NumTstTakr": str,
						"AvgScrRead": str,
						"AvgScrEng": str,
						"AvgScrMath": str,
						"AvgScrSci": str,
						"CompositeAvgScr": str,
						"PctGE21": str
					})
 
transposed_act19_df = pd.melt(act19_df, id_vars=["CDS","CDCode","RType","SName","DName","NumTstTakr"],
							value_vars=["AvgScrRead","AvgScrEng","AvgScrMath","AvgScrSci","CompositeAvgScr","PctGE21"])

transposed_act19_df.to_csv("transposed_act19.txt",index=None,sep='\t')

# dealing with cgr12mo18.txt file
cgr12mo18_df = pd.read_csv("cgr12mo18.txt",
					sep='\t',
					dtype={
						"AcademicYear": str,
						"AggregateLevel": str,
						"CountyCode": str,
						"DistrictCode": str,
						"SchoolCode": str,
						"CountyName": str,
						"DistrictName": str,
						"SchoolName": str,
						"CharterSchool": str,
						"AlternativeSchoolAccountabilityStatus": str,
						"ReportingCategory": str,
						"High School Completers": str,
						"College Going Rate - Total (12 Months)": str
					})
 
transposed_cgr12mo18_df = pd.melt(cgr12mo18_df, id_vars=["AcademicYear","AggregateLevel","CountyCode","DistrictCode","SchoolCode","CountyName",
									"DistrictName","SchoolName","CharterSchool","AlternativeSchoolAccountabilityStatus","ReportingCategory","High School Completers"],
							value_vars=["College Going Rate - Total (12 Months)"])

transposed_cgr12mo18_df.to_csv("transposed_cgr12mo18.txt",index=None,sep='\t')



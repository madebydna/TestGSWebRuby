#!/usr/bin/env python

import pandas as pd

# using read_excel to use the excel files directly
raw_CCADFile = pd.read_excel("CCAD.xls")
raw_DCADFile = pd.read_excel("DCAD.xls")
raw_SCADFile = pd.read_excel("SCAD.xls")
raw_CampusDataDownloadFile = pd.read_excel("Campus_Data_Download_4yr_2018_v2.xlsx",sheet_name='Comp_2018_4yr')
raw_DistrictDataDownloadFile = pd.read_excel("District_Data_Download_4yr_2018_v2.xlsx",sheet_name='Comp_2018_4yr')
raw_CTXIHEFile = pd.read_excel("CTXIHE_2018.xls")
raw_DTXIHEFile = pd.read_excel("DTXIHE_2018.xls")
raw_STXIHEFile = pd.read_excel("STXIHE_2018.xls")

# Transposing and selecting the columns needed
transposed_CCADFile = pd.melt(raw_CCADFile,
								id_vars=["CAMPUS"],
								value_vars=["C20CAA18R", "C30CAA18R", "C40CAA18R", "CA0CAA18R", "CA0CAE18R", "CA0CAM18R", "CB0CAA18R",
								"CE0CAA18R", "CF0CAA18R", "CH0CAA18R", "CI0CAA18R", "CM0CAA18R", "CW0CAA18R", "C20CSA18R", "C30CSA18R",
								"C40CSA18R", "CA0CSA18R", "CA0CSE18R", "CA0CSM18R", "CB0CSA18R", "CE0CSA18R", "CF0CSA18R", "CH0CSA18R", 
								"CI0CSA18R", "CM0CSA18R", "CW0CSA18R"])

transposed_DCADFile = pd.melt(raw_DCADFile,
								id_vars=["DISTRICT"],
								value_vars=["D20CAA18R", "D30CAA18R", "D40CAA18R", "DA0CAA18R", "DA0CAE18R", "DA0CAM18R", "DB0CAA18R",
								"DE0CAA18R", "DF0CAA18R", "DH0CAA18R", "DI0CAA18R", "DM0CAA18R", "DW0CAA18R", "D20CSA18R", "D30CSA18R",
								"D40CSA18R", "DA0CSA18R", "DA0CSE18R", "DA0CSM18R", "DB0CSA18R", "DE0CSA18R", "DF0CSA18R", "DH0CSA18R", 
								"DI0CSA18R", "DM0CSA18R", "DW0CSA18R"])

transposed_SCADFile = pd.melt(raw_SCADFile,
								value_vars=["S20CAA18R", "S30CAA18R", "S40CAA18R", "SA0CAA18R", "SA0CAE18R", "SA0CAM18R", "SB0CAA18R",
								"SE0CAA18R", "SF0CAA18R", "SH0CAA18R", "SI0CAA18R", "SM0CAA18R", "SW0CAA18R", "S20CSA18R", "S30CSA18R",
								"S40CSA18R", "SA0CSA18R", "SA0CSE18R", "SA0CSM18R", "SB0CSA18R", "SE0CSA18R", "SF0CSA18R", "SH0CSA18R", 
								"SI0CSA18R", "SM0CSA18R", "SW0CSA18R"])

transposed_CampusDataDownloadFile = pd.melt(raw_CampusDataDownloadFile, 
								id_vars=["CALC_FOR_STATE_ACCT","CAMPUS","CAMPNAME","CAMP_ALLD","CAMP_AAD","CAMP_ASD","CAMP_HSD", "CAMP_MUD",
								"CAMP_NAD", "CAMP_PID", "CAMP_WHD", "CAMP_ECND", "CAMP_NECND", "CAMP_FEMD", "CAMP_MALD", "CAMP_LEPHSD", 
								"CAMP_SPED"],
								value_vars=["CAMP_ALLR_GRAD","CAMP_AAR_GRAD","CAMP_ASR_GRAD", "CAMP_HSR_GRAD", "CAMP_MUR_GRAD", "CAMP_NAR_GRAD",
								"CAMP_PIR_GRAD", "CAMP_WHR_GRAD", "CAMP_ECNR_GRAD", "CAMP_NECNR_GRAD", "CAMP_FEMR_GRAD", "CAMP_MALR_GRAD", 
								"CAMP_LEPHSR_GRAD", "CAMP_SPER_GRAD"])

transposed_DistrictDataDownloadFile = pd.melt(raw_DistrictDataDownloadFile, 
								id_vars=["CALC_FOR_STATE_ACCT","DISTRICT","DISTNAME","DIST_ALLD","DIST_AAD","DIST_ASD","DIST_HSD", "DIST_MUD",
								"DIST_NAD", "DIST_PID", "DIST_WHD", "DIST_ECND", "DIST_NECND", "DIST_FEMD", "DIST_MALD", "DIST_LEPHSD", 
								"DIST_SPED"],
								value_vars=["DIST_ALLR_GRAD","DIST_AAR_GRAD","DIST_ASR_GRAD", "DIST_HSR_GRAD", "DIST_MUR_GRAD", "DIST_NAR_GRAD",
								"DIST_PIR_GRAD", "DIST_WHR_GRAD", "DIST_ECNR_GRAD", "DIST_NECNR_GRAD", "DIST_FEMR_GRAD", "DIST_MALR_GRAD", 
								"DIST_LEPHSR_GRAD", "DIST_SPER_GRAD"])

transposed_CTXIHEFile = pd.melt(raw_CTXIHEFile,
								id_vars=["CAMPUS"],
								value_vars=["C2HEE18R", "C3HEE18R", "C4HEE18R", "CAHEE18R", "CBHEE18R", "CEHEE18R", "CHHEE18R", "CIHEE18R", 
								"CLHEE18R", "CSHEE18R", "CWHEE18R", "C2HEC18R", "C3HEC18R", "C4HEC18R", "CAHEC18R", "CBHEC18R", "CEHEC18R", 
								"CHHEC18R", "CIHEC18R", "CLHEC18R", "CSHEC18R", "CWHEC18R"])

transposed_DTXIHEFile = pd.melt(raw_DTXIHEFile,
								id_vars=["DISTRICT"],
								value_vars=["D2HEE18R", "D3HEE18R", "D4HEE18R", "DAHEE18R", "DBHEE18R", "DEHEE18R", "DHHEE18R", "DIHEE18R", 
								"DLHEE18R", "DSHEE18R", "DWHEE18R", "D2HEC18R", "D3HEC18R", "D4HEC18R", "DAHEC18R", "DBHEC18R", "DEHEC18R", 
								"DHHEC18R", "DIHEC18R", "DLHEC18R", "DSHEC18R", "DWHEC18R"])

transposed_STXIHEFile = pd.melt(raw_STXIHEFile,
								value_vars=["S2HEE18R", "S3HEE18R", "S4HEE18R", "SAHEE18R", "SBHEE18R", "SEHEE18R", "SHHEE18R", "SIHEE18R", 
								"SLHEE18R", "SSHEE18R", "SWHEE18R", "S2HEC18R", "S3HEC18R", "S4HEC18R", "SAHEC18R", "SBHEC18R", "SEHEC18R", 
								"SHHEC18R", "SIHEC18R", "SLHEC18R", "SSHEC18R", "SWHEC18R"])


# convert the transposed data frames to .txt files
transposed_CCADFile.to_csv("transposed_CCADFile.txt",index=None,sep='\t')
transposed_DCADFile.to_csv("transposed_DCADFile.txt",index=None,sep='\t')
transposed_SCADFile.to_csv("transposed_SCADFile.txt",index=None,sep='\t')
transposed_CampusDataDownloadFile.to_csv("transposed_CampusDataDownloadFile.txt",index=None,sep='\t')
transposed_DistrictDataDownloadFile.to_csv("transposed_DistrictDataDownloadFile.txt",index=None,sep='\t')
transposed_CTXIHEFile.to_csv("transposed_CTXIHEFile.txt",index=None,sep='\t')
transposed_DTXIHEFile.to_csv("transposed_DTXIHEFile.txt",index=None,sep='\t')
transposed_STXIHEFile.to_csv("transposed_STXIHEFile.txt",index=None,sep='\t')






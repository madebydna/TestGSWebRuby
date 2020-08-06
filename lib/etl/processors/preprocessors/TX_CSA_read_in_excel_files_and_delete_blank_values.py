#!/usr/bin/env python

#!/usr/bin/env python

import pandas as pd

# using read_excel to use the excel files directly
raw_SCADFile = pd.read_excel("SCAD.xls")
raw_ACTDistrictFile = pd.read_excel("act_district_data_class_2018.xlsx")
raw_ACTCampusFile = pd.read_excel("act_campus_data_class_2018.xlsx")
raw_SATDistrictFile = pd.read_excel("sat_district_data_class_2018.xlsx")
raw_SATCampusFile = pd.read_excel("sat_campus_data_class_2018.xlsx")
raw_DistrictDataDownloadFile = pd.read_excel("District_Data_Download_4yr_2018_v2.xlsx",sheet_name='Comp_2018_4yr')
raw_CampusDataDownloadFile = pd.read_excel("Campus_Data_Download_4yr_2018_v2.xlsx",sheet_name='Comp_2018_4yr')
raw_CTXIHEFile = pd.read_excel("CTXIHE_2018.xls")
raw_DTXIHEFile = pd.read_excel("DTXIHE_2018.xls")
raw_STXIHEFile = pd.read_excel("STXIHE_2018.xls")


# Transposing and selecting the columns needed
transposed_SCADFile = pd.melt(raw_SCADFile,
								value_vars=["SB0CAA18R","SB0CAE18R","SB0CAM18R","SB0CAC18R","SA0CAA18R","SA0CAE18R","SA0CAM18R","SA0CAC18R","SI0CAA18R","SI0CAE18R",
											"SI0CAM18R","SI0CAC18R","S30CAA18R","S30CAE18R","S30CAM18R","S30CAC18R","SE0CAA18R","SE0CAE18R","SE0CAM18R","SE0CAC18R",
											"SF0CAA18R","SF0CAE18R","SF0CAM18R","SF0CAC18R","SH0CAA18R","SH0CAE18R","SH0CAM18R","SH0CAC18R","SM0CAA18R","SM0CAE18R",
											"SM0CAM18R","SM0CAC18R","S40CAA18R","S40CAE18R","S40CAM18R","S40CAC18R","S20CAA18R","S20CAE18R","S20CAM18R","S20CAC18R",
											"SW0CAA18R","SW0CAE18R","SW0CAM18R","SW0CAC18R","SB0CSA18R","SB0CSE18R","SB0CSM18R","SA0CSA18R","SA0CSE18R","SA0CSM18R",
											"SI0CSA18R","SI0CSE18R","SI0CSM18R","S30CSA18R","S30CSE18R","S30CSM18R","SE0CSA18R","SE0CSE18R","SE0CSM18R","SF0CSA18R",
											"SF0CSE18R","SF0CSM18R","SH0CSA18R","SH0CSE18R","SH0CSM18R","SM0CSA18R","SM0CSE18R","SM0CSM18R","S40CSA18R","S40CSE18R",
											"S40CSM18R","S20CSA18R","S20CSE18R","S20CSM18R","SW0CSA18R","SW0CSE18R","SW0CSM18R"])


transposed_ACTDistrictFile = pd.melt(raw_ACTDistrictFile, 
									id_vars = ["Group", "District", "DistName", "Grads_Mskd", "Exnees_Mskd"],
									value_vars = ["English", "Math", "Reading", "Science", "Compos","Part_Rate", "Above_Crit_Rate"])
transposed_ACTDistrictFile.dropna(subset = ["value"], inplace=True)


transposed_ACTCampusFile = pd.melt(raw_ACTCampusFile, 
									id_vars = ["Group", "Campus", "CampName", "Grads_Mskd", "Exnees_Mskd"],
									value_vars = ["English", "Math", "Reading", "Science", "Compos","Part_Rate", "Above_Crit_Rate"])
transposed_ACTCampusFile.dropna(subset = ["value"], inplace=True)


transposed_SATDistrictFile = pd.melt(raw_SATDistrictFile, 
									id_vars = ["Group", "District", "DistName", "Grads_Mskd", "Exnees_Mskd"],
									value_vars = ["ERW", "Math", "Total","Part_Rate", "Above_Crit_Rate"])
transposed_SATDistrictFile.dropna(subset = ["value"], inplace=True)


transposed_SATCampusFile = pd.melt(raw_SATCampusFile, 
									id_vars = ["Group", "Campus", "CampName", "Grads_Mskd", "Exnees_Mskd"],
									value_vars = ["ERW", "Math", "Total","Part_Rate", "Above_Crit_Rate"])
transposed_SATCampusFile.dropna(subset = ["value"], inplace=True)


transposed_DistrictDataDownloadFile = pd.melt(raw_DistrictDataDownloadFile, 
								id_vars=["CALC_FOR_STATE_ACCT","DISTRICT","DISTNAME","DIST_ALLD","DIST_AAD","DIST_ASD","DIST_HSD", "DIST_MUD",
								"DIST_NAD", "DIST_PID", "DIST_WHD", "DIST_ECND", "DIST_NECND", "DIST_FEMD", "DIST_MALD", "DIST_LEPHSD", 
								"DIST_SPED"],
								value_vars=["DIST_ALLR_GRAD","DIST_AAR_GRAD","DIST_ASR_GRAD", "DIST_HSR_GRAD", "DIST_MUR_GRAD", "DIST_NAR_GRAD",
								"DIST_PIR_GRAD", "DIST_WHR_GRAD", "DIST_ECNR_GRAD", "DIST_NECNR_GRAD", "DIST_FEMR_GRAD", "DIST_MALR_GRAD", 
								"DIST_LEPHSR_GRAD", "DIST_SPER_GRAD"])


transposed_CampusDataDownloadFile = pd.melt(raw_CampusDataDownloadFile, 
								id_vars=["CALC_FOR_STATE_ACCT","CAMPUS","CAMPNAME","CAMP_ALLD","CAMP_AAD","CAMP_ASD","CAMP_HSD", "CAMP_MUD",
								"CAMP_NAD", "CAMP_PID", "CAMP_WHD", "CAMP_ECND", "CAMP_NECND", "CAMP_FEMD", "CAMP_MALD", "CAMP_LEPHSD", 
								"CAMP_SPED"],
								value_vars=["CAMP_ALLR_GRAD","CAMP_AAR_GRAD","CAMP_ASR_GRAD", "CAMP_HSR_GRAD", "CAMP_MUR_GRAD", "CAMP_NAR_GRAD",
								"CAMP_PIR_GRAD", "CAMP_WHR_GRAD", "CAMP_ECNR_GRAD", "CAMP_NECNR_GRAD", "CAMP_FEMR_GRAD", "CAMP_MALR_GRAD", 
								"CAMP_LEPHSR_GRAD", "CAMP_SPER_GRAD"])


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
transposed_SCADFile.to_csv("transposed_SCADFile.txt",index=None,sep='\t')
transposed_ACTDistrictFile.to_csv("transposed_ACTDistrictFile.txt",index=None,sep='\t')
transposed_ACTCampusFile.to_csv("transposed_ACTCampusFile.txt",index=None,sep='\t')
transposed_SATDistrictFile.to_csv("transposed_SATDistrictFile.txt",index=None,sep='\t')
transposed_SATCampusFile.to_csv("transposed_SATCampusFile.txt",index=None,sep='\t')
transposed_CampusDataDownloadFile.to_csv("transposed_CampusDataDownloadFile.txt",index=None,sep='\t')
transposed_DistrictDataDownloadFile.to_csv("transposed_DistrictDataDownloadFile.txt",index=None,sep='\t')
transposed_CTXIHEFile.to_csv("transposed_CTXIHEFile.txt",index=None,sep='\t')
transposed_DTXIHEFile.to_csv("transposed_DTXIHEFile.txt",index=None,sep='\t')
transposed_STXIHEFile.to_csv("transposed_STXIHEFile.txt",index=None,sep='\t')






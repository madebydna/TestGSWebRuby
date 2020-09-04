library(readr)
library(dplyr)
library(readxl)
library(stringr)

setwd("~/Documents/Metrics_Load/ia/CSA/2019")

#read in crosswalk
#school
school_crosswalk <- read_excel("IA_crosswalk_school_2020.xlsx", col_names = TRUE, col_types = "text")
#identify bad state_ids to drop from crosswalk
bad_state_ids <- c("0252 172","1332 109","4014 109","2664 172",
                   "5510 209","194599 172","0594 118","0729 118",
                   "1337 951","1701 118","7056 118","1737 988",
                   "5337 109","2016 109","3119 109","3600 118",
                   "4271 118","4536 118","4662 118","4725 127",
                   "5283 118","6219 120","6795 111","6840 118",
                   "6943 172","7110 118","1737 977") 
school_crosswalk <- school_crosswalk[!school_crosswalk$state_id %in% bad_state_ids, ] #dropping problem children rows

#get full length state_ids for loading
#read in files
#school
formatted_school_ids <- read_delim("ia_state_ids_school.txt", delim = "\t", col_names = TRUE, col_types = cols(.default = "c"))
bad_formmated_state_ids <- c("094599 172")
formatted_school_ids <- formatted_school_ids[!formatted_school_ids$full_state_id %in% bad_formmated_state_ids, ]
formatted_school_ids <- rbind(formatted_school_ids, "523141 114" = c("523141 114","3141 114", "Liberty High School"))
#merge in full state_id and name to provided crosswalk
school_crosswalk <- left_join(school_crosswalk,formatted_school_ids,by=c("state_id"="small_state_id"))
#district
formatted_district_ids <- read_delim("ia_state_ids_district.txt", delim = "\t", col_names = TRUE, col_types = cols(.default = "c"))

#read in ACT performance files and merge in state_ids
act <- read_excel("Iowa_2019_Public_Schools_Graduating_Class_5yr_trends_School Level_no small Ns.xlsx", col_names = TRUE, col_types = "text", skip = 2)
act_crosswalked <- left_join(act,school_crosswalk,by=c("ACT HS Code"="act_code"))

#check for missing state_ids
na_schools <- subset(act_crosswalked, is.na(act_crosswalked$name))
#na_schools <- na_schools[c(1:5,18:20)] #lookup problem children until problem children go away

#read in PS file
ps <- read_delim("Iowa GreatSchools Request File v2.csv", delim = ",", col_names = TRUE, col_types = cols(.default = "c"))
#fix district id and school id
ps$fixed_district_code <- str_pad(ps$DISTRICT_CODE, 4, pad = "0")
ps$fixed_school_code <- str_sub(ps$SCHOOL_CODE,start = -3)

#merge in school and district data
#combine district and school full state id dataframes
full_ids <- rbind(formatted_school_ids,formatted_district_ids)
#create state_id field to match to crosswalk
ps <- mutate(ps, small_state_id = if_else(ps$AGGREGATION_LEVEL == "STATE", "state",
                                          if_else(ps$AGGREGATION_LEVEL == "DISTRICT", ps$fixed_district_code,
                                                  if_else(ps$AGGREGATION_LEVEL == "SCHOOL", paste(ps$fixed_district_code,ps$fixed_school_code,sep = " "), "ERROR"))))
#merge in full state_id
ps <- mutate(ps, small_state_id = if_else(ps$small_state_id == "1737 987", "1737 988",
                                          if_else(ps$small_state_id == "4860 127", "4860 109",
                                                  if_else(ps$small_state_id == "1053 000", "skip", 
                                                          if_else(ps$small_state_id == "3715 000", "skip", ps$small_state_id))))) #fixing problem children discovered below
ps_crosswalked <- left_join(ps,full_ids,by="small_state_id")
ps_crosswalked <- mutate(ps_crosswalked, full_state_id = if_else(ps_crosswalked$AGGREGATION_LEVEL == "STATE", "state",
                                                                 if_else(ps_crosswalked$small_state_id == "skip", "skip", ps_crosswalked$full_state_id)))
na_ps <- subset(ps_crosswalked, is.na(ps_crosswalked$full_state_id)) #see where we have problem children

#check you didn't match multiple schools to the same source data before writing the files
nrow(act)==nrow(act_crosswalked)
nrow(ps)==nrow(ps_crosswalked)

#write files for loading
write_delim(act_crosswalked,"act_final.txt",delim = "\t", na = "NA", col_names = TRUE)
write_delim(ps_crosswalked,"ps_final.txt",delim = "\t", na = "NA", col_names = TRUE)


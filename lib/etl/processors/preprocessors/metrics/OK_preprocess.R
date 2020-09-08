library(readr)
library(dplyr)
library(readxl)
library(stringr)

setwd("~/Documents/Metrics_Load/ok/CSA/2018")

#read in performance files
#ACT
#district
act_district <- read_excel("2018-ACT-Scores. CHOCTAW district replaced with HUGO.xlsx", sheet = "By District", col_names = TRUE, col_types = "text", skip = 3,n_max = 499)
colnames(act_district)
act_district <- act_district %>% rename("District" = ...1 , "Composite Score" = ...6, "Number of Testers" = ...7)
act_district <- act_district %>% add_row(District = "state",
                                         Engllish = "18.65",	
                                         Math = "19.06",
                                         Reading = "20.6",
                                         Science = "19.83",
                                         "Composite Score" = "19.66",
                                         "Number of Testers" = "41092")
#school
act_school <- read_excel("2018-ACT-Scores. CHOCTAW district replaced with HUGO.xlsx", sheet = "By High School", col_names = FALSE, col_types = "text", skip = 5, n_max = 691)
school_column_names <- c("County","Dist No","District","High School","ACT CODE","Engllish","Math","Reading","Science","Composite Score","Number of Testers")
names(act_school) <- school_column_names
colnames(act_school)
#drop county mean rows and blank rows
act_school_clean <- filter(act_school, !is.na(act_school$`High School`))

#PS
#Enrollment
#district
ps_enroll_district <- read_excel("2017-18-HSIR-College-Going-Rates.xlsx", sheet = "By District", col_names = TRUE, col_types = "text", skip = 5,n_max = 432)
colnames(ps_enroll_district)
ps_enroll_district <- ps_enroll_district %>% rename("Number of 2017 Public High School Graduates" = ...2, 
                                                    "Number of 2017 High School Graduates Attending College/University Directly After High School (in Fall 2017)" = ...3,
                                                    "Percent Direct to College-Going in the Fall" = ...4,
                                                    "Number  of 2017 High School Graduates Attending College/University Anytime 2017-18" = ...5,
                                                    "Percent Direct to  College-Going in the Academic Year" = ...6,
                                                    "Number Attending College/University for the First Timein 2017-18 - from any High School Graduating Class" = ...7)
#school
ps_enroll_school <- read_excel("2017-18-HSIR-College-Going-Rates.xlsx", sheet = "By High School", col_names = FALSE, col_types = "text", skip = 4)
colnames(ps_enroll_school)
ps_enroll_school <- ps_enroll_school %>% rename("County" = ...1,
                                                "ACT Code" = ...2,
                                                "High School" = ...3,
                                                "Number of 2017 Public High School Graduates" = ...4, 
                                                "Number of 2017 High School Graduates Attending College/University Directly After High School (in Fall 2017)" = ...5,
                                                "Percent Direct to College-Going in the Fall" = ...6,
                                                "Number  of 2017 High School Graduates Attending College/University Anytime 2017-18" = ...7,
                                                "Percent Direct to  College-Going in the Academic Year" = ...8,
                                                "Number Attending College/University for the First Timein 2017-18 - from any High School Graduating Class" = ...9)
ps_enroll_school_clean <- filter(ps_enroll_school, !is.na(ps_enroll_school$`High School`))

#Remediation
#district
ps_remed_district <- read_excel("2017-18-HSIR-Remediation.xlsx", sheet = "By District", col_names = TRUE, col_types = "text", skip = 7, n_max = 424)
colnames(ps_remed_district)
ps_remed_district <- ps_remed_district %>% rename("County" = ...1,
                                                  "science_n" = N...3,
                                                  "science_pct" = "%...4",
                                                  "english_n" = N...5,
                                                  "english_pct" = "%...6",
                                                  "math_n" = N...7,
                                                  "math_pct" = "%...8",
                                                  "reading_n" = N...9,
                                                  "reading_pct" = "%...10",
                                                  "unduplicated_n" = N...11,
                                                  "unduplicated_pct" = "%...12")

#school
ps_remed_school <- read_excel("2017-18-HSIR-Remediation.xlsx", sheet = "By High School", col_names = TRUE, col_types = "text", skip = 6)
colnames(ps_remed_school)
ps_remed_school <- ps_remed_school %>% rename("science_n" = N...5,
                                                  "science_pct" = "%...6",
                                                  "english_n" = N...7,
                                                  "english_pct" = "%...8",
                                                  "math_n" = N...9,
                                                  "math_pct" = "%...10",
                                                  "reading_n" = N...11,
                                                  "reading_pct" = "%...12",
                                                  "unduplicated_n" = N...13,
                                                  "unduplicated_pct" = "%...14")
ps_remed_school_clean <- filter(ps_remed_school, !is.na(ps_remed_school$`High School`))

#read in crosswalks
district_crosswalk <- read_excel("OK_crosswalk_district_2020_v3.xlsx", col_names = TRUE, col_types = "text")
school_crosswalk <- read_excel("OK_crosswalk_school_2020.xlsx", col_names = TRUE, col_types = "text")
colnames(district_crosswalk)
colnames(school_crosswalk)

#merge in state_ids
act_district_crosswalked <- left_join(act_district,district_crosswalk,by=c("District"="entity_name"))
act_school_crosswalked <- left_join(act_school_clean,school_crosswalk,by=c("ACT CODE"="act_code"))
ps_enroll_district_crosswalked <- left_join(ps_enroll_district,district_crosswalk,by=c("District Name" = "entity_name"))
ps_remed_district_crosswalked <- left_join(ps_remed_district,district_crosswalk,by=c("County" = "entity_name"))
ps_enroll_school_crosswalked <- left_join(ps_enroll_school_clean,school_crosswalk,by=c("ACT Code"="act_code"))
ps_remed_school_crosswalked <- left_join(ps_remed_school_clean,school_crosswalk,by=c("ACT Code"="act_code"))

#check we didn't match entities to multiple codes
nrow(act_district)==nrow(act_district_crosswalked)
nrow(act_school)==nrow(act_school_crosswalked)
nrow(ps_enroll_district)==nrow(ps_enroll_district_crosswalked)
nrow(ps_remed_district)==nrow(ps_remed_district_crosswalked)
nrow(ps_enroll_school_clean)==nrow(ps_enroll_school_crosswalked)
nrow(ps_remed_school_clean)==nrow(ps_remed_school_crosswalked)

#write files
write_delim(act_district_crosswalked,"act_district_final.txt",delim = "\t", na = "NA", col_names = TRUE)
write_delim(act_school_crosswalked,"act_school_final.txt",delim = "\t", na = "NA", col_names = TRUE)
write_delim(ps_enroll_district_crosswalked,"ps_enroll_district_final.txt",delim = "\t", na = "NA", col_names = TRUE)
write_delim(ps_enroll_school_crosswalked,"ps_enroll_school_final.txt",delim = "\t", na = "NA", col_names = TRUE)
write_delim(ps_remed_district_crosswalked,"ps_remed_district_final.txt",delim = "\t", na = "NA", col_names = TRUE)
write_delim(ps_remed_school_crosswalked,"ps_remed_school_final.txt",delim = "\t", na = "NA", col_names = TRUE)


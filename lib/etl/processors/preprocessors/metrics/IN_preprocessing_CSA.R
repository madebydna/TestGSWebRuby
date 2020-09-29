library(readr)
library(dplyr)
library(readxl)
library(stringr)
library(janitor)
library(tidyverse)

setwd("~/Documents/Metrics_Load/in/CSA/2018")
list.files(getwd())

#GRADUATION
grad_file <- "2019-federal-grad-rate-data-20191231.xlsx"
excel_sheets(grad_file)

#STATE
state_disagg <- read_xlsx(grad_file, sheet = "State_disagg", col_types = "text", skip = 1)

clean_state_disagg <- state_disagg %>%  
  clean_names() %>% 
  rename(breakdown=student_demographic,
         numerator = graduates,
         value = x2019_federal_graduation_rate) %>%
  mutate(entity_type = 'state',
         state_id = 'state',
         year = 2019,
         data_type = 'graduation rate',
         data_type_id = 443,
         subject = NA,
         grade = NA) %>%
  filter(!str_detect(breakdown, 'Non-Public|Public|School Demographic|\\*Totals may not match due to \"Unknown\" students|Unknown|Charter Schools'))

write_delim(clean_state_disagg, "state_grad.txt", delim = "\t", quote_escape = FALSE)

#DISTRICT
district_disagg <- read_xlsx(grad_file, sheet = "Corp Disagg", col_names = FALSE, col_types = "text", na = "***", skip = 3)
proper_headers <- find_column_headers(file=grad_file, sheet="Corp Disagg", n_skip=1, n_rows=2, n_fill=TRUE, name_clean=FALSE) 
names(district_disagg) <- proper_headers

clean_district_disagg <- district_disagg %>%
  mutate(entity_type = 'district',
         year = 2019,
         data_type = 'graduation rate',
         data_type_id = 443,
         subject = NA,
         grade = NA) %>%
  rename(state_id = 'Corp Id') %>%
  filter(!is.na(state_id)) %>%
  pivot_longer(
    cols = ends_with('Graduation Rate'), names_to = 'tmp', values_to = 'value') %>%
  pivot_longer(
    cols = ends_with("Cohort Count"), names_to = 'tmp2', values_to = 'cohort_count') %>%
  separate(tmp, into=c('breakdown', 'leftover'), sep='_', extra='merge') %>% 
  separate(tmp2, into=c('breakdown2', 'leftover2'), sep='_', extra='merge') %>% 
  filter(breakdown==breakdown2) %>%
  clean_names() %>%
  select(
    year, 
    data_type,
    data_type_id,
    entity_type,
    corporation_name,
    state_id,
    subject, grade, breakdown, 
    cohort_count,
    value)

#check you didn't drop any values
length(unique(na.omit(district_disagg$`Corp Id`)))*length(unique(clean_district_disagg$breakdown))==nrow(clean_district_disagg)

clean_district_disagg %>% 
  group_by(year, entity_type, data_type_id, state_id, breakdown, subject, grade) %>% 
  summarize(count = n()) %>% 
  filter(count > 1)

write_delim(clean_district_disagg, "district_grad.txt", delim = "\t")

#PUBLIC SCHOOLS
public_school_disagg <- read_xlsx(grad_file, sheet = "School Pub Disagg", col_names = FALSE, col_types = "text", na = "***", skip = 3)
proper_headers <- find_column_headers(file=grad_file, sheet="School Pub Disagg", n_skip=1, n_rows=2, n_fill=TRUE, name_clean=FALSE)   
names(public_school_disagg) <- proper_headers

clean_public_school_disagg <- public_school_disagg %>%
  mutate(entity_type = 'school',
         year = 2019,
         data_type = 'graduation rate',
         data_type_id = 443,
         subject = NA,
         grade = NA) %>%
  rename(state_id = 'School Id') %>%
  pivot_longer(
    cols = ends_with('Graduation Rate'), names_to = 'tmp', values_to = 'value') %>%
  pivot_longer(
    cols = ends_with("Cohort Count"), names_to = 'tmp2', values_to = 'cohort_count') %>%
  separate(tmp, into=c('breakdown', 'leftover'), sep='_', extra='merge') %>% 
  separate(tmp2, into=c('breakdown2', 'leftover2'), sep='_', extra='merge') %>% 
  filter(breakdown==breakdown2) %>%
  clean_names() %>%
  select(
    year, 
    data_type,
    data_type_id,
    entity_type,
    corp_id,
    corporation_name,
    state_id,
    school_name,
    subject, grade, breakdown, 
    cohort_count,
    value)

#check you didn't drop any values
length(unique(na.omit(public_school_disagg$`School Id`)))*length(unique(clean_public_school_disagg$breakdown))==nrow(clean_public_school_disagg)

clean_public_school_disagg %>% 
  group_by(year, entity_type, data_type_id, state_id, breakdown, subject, grade) %>% 
  summarize(count = n()) %>% 
  filter(count > 1)

write_delim(clean_public_school_disagg, "public_school_grad.txt", delim = "\t")


#PRIVATE SCHOOLS
private_school_disagg <- read_xlsx(grad_file, sheet = "School Non-Pub Disagg", col_names = FALSE, col_types = "text", na = "***", skip = 3)
proper_headers <- find_column_headers(file=grad_file, sheet="School Non-Pub Disagg", n_skip=1, n_rows=2, n_fill=TRUE, name_clean=FALSE)   
names(private_school_disagg) <- proper_headers

clean_private_school_disagg <- private_school_disagg %>%
  mutate(entity_type = 'school',
         year = 2019,
         data_type = 'graduation rate',
         data_type_id = 443,
         subject = NA,
         grade = NA) %>%
  rename(state_id = 'School Id') %>%
  pivot_longer(
    cols = ends_with('Graduation Rate'), names_to = 'tmp', values_to = 'value') %>%
  pivot_longer(
    cols = ends_with("Cohort Count"), names_to = 'tmp2', values_to = 'cohort_count') %>%
  separate(tmp, into=c('breakdown', 'leftover'), sep='_', extra='merge') %>% 
  separate(tmp2, into=c('breakdown2', 'leftover2'), sep='_', extra='merge') %>% 
  filter(breakdown==breakdown2) %>%
  clean_names() %>%
  select(
    year, 
    data_type,
    data_type_id,
    entity_type,
    corp_id,
    corporation_name,
    state_id,
    school_name,
    subject, grade, breakdown, 
    cohort_count,
    value)

#check you didn't drop any values
length(unique(na.omit(private_school_disagg$`School Id`)))*length(unique(clean_private_school_disagg$breakdown))==nrow(clean_private_school_disagg)

clean_private_school_disagg %>% 
  group_by(year, entity_type, data_type_id, state_id, breakdown, subject, grade) %>% 
  summarize(count = n()) %>% 
  filter(count > 1)

write_delim(clean_private_school_disagg, "private_school_grad.txt", delim = "\t")

#ACT
#DISTRICT
act_district <- read_xlsx("act-corporation-and-school.xlsx", sheet = "Corporation", col_names = TRUE, col_types = "text", na = "***")

clean_act_district <- act_district %>%
  clean_names() %>%
  filter(year=='2017-18') %>%
  mutate(entity_type = 'district',
         year = 2018,
         grade = 'All',
         breakdown = 'All Students') %>%
  rename(state_id = 'corp_no') %>%
  pivot_longer(
    cols = c(
      "percent_graduates_taking_act",
      "avg_composite_score","avg_english_score",
      "avg_math_score","avg_reading_score","avg_science_score" ), 
    names_to = 'data_type_subject', values_to = 'value') %>%
  mutate(data_type=ifelse(str_detect(data_type_subject,regex('^avg_.*')),'ACT average score','ACT participation'),
         data_type_id=ifelse(data_type=='ACT average score',448,396),
         subject=ifelse(str_detect(data_type_subject,regex('^avg_.*')),str_to_title(str_remove_all(str_extract(data_type_subject,'_([a-z]+)_'),'_')),'Composite'),
         cohort_count=ifelse(data_type=='ACT average score',took_act_n,graduates_n)) %>% 
  select(
    year, 
    data_type,
    data_type_id,
    entity_type,
    corp_name,
    state_id,
    subject, grade, breakdown, 
    cohort_count,
    value)

#check you didn't drop anything you didn't mean to
sum(act_district$Year=="2017-18")==length(unique(clean_act_district$state_id))


clean_act_district %>% 
  group_by(year, entity_type, data_type_id, state_id, breakdown, subject, grade) %>% 
  summarize(count = n()) %>% 
  filter(count > 1)

write_delim(clean_act_district, "act_district.txt", delim = "\t")

#SCHOOL
act_school <- read_xlsx("act-corporation-and-school.xlsx", sheet = "School", col_names = TRUE, col_types = "text", na = "***")

clean_act_school <- act_school %>%
  clean_names() %>%
  filter(year=='2017-18') %>%
  mutate(entity_type = 'school',
         year = 2018,
         grade = 'All',
         breakdown = 'All Students') %>%
  rename(state_id = 'sch_no') %>%
  pivot_longer(
    cols = c(
      "percent_graduates_taking_act",
      "avg_composite_score","avg_english_score",
      "avg_math_score","avg_reading_score","avg_science_score" ), 
    names_to = 'data_type_subject', values_to = 'value') %>%
  mutate(data_type=ifelse(str_detect(data_type_subject,regex('^avg_.*')),'ACT average score','ACT participation'),
         data_type_id=ifelse(data_type=='ACT average score',448,396),
         subject=ifelse(str_detect(data_type_subject,regex('^avg_.*')),str_to_title(str_remove_all(str_extract(data_type_subject,'_([a-z]+)_'),'_')),'Composite'),
         cohort_count=ifelse(data_type=='ACT average score',took_act_n,graduates_n)) %>% 
  filter(subject!='Writing') %>%
  select(
    year, 
    data_type,
    data_type_id,
    entity_type,
    corp_no,
    corp_name,
    state_id,
    sch_name,
    subject, grade, breakdown, 
    cohort_count,
    value)

#check you didn't drop anything you didn't mean to
sum(act_school$Year=="2017-18")==length(unique(clean_act_school$state_id))

clean_act_school %>% 
  group_by(year, entity_type, data_type_id, state_id, breakdown, subject, grade) %>% 
  summarize(count = n()) %>% 
  filter(count > 1)

write_delim(clean_act_school, "act_school.txt", delim = "\t")

#SAT
#DISTRICT
sat_district <- read_xlsx("sat-corporation-and-school.xlsx", sheet = "Corporation", col_names = TRUE, col_types = "text", na = "***")

clean_sat_district <- sat_district %>%
  clean_names() %>%
  filter(year=='2017-18',
         corp_id!='9625') %>%
  mutate(entity_type = 'district',
         year = 2018,
         grade = 'All',
         breakdown = 'All Students') %>%
  rename(state_id = 'corp_id') %>%
  pivot_longer(
    cols = c(
      "percent_graduates_taking_sat",
      "avg_composite_math_and_verbal","avg_sat_math_score","avg_sat_reading_score"),
    names_to = 'data_type_subject', values_to = 'value') %>%
  mutate(data_type=ifelse(str_detect(data_type_subject,regex('^avg_.*')),'SAT average score','SAT participation'),
         data_type_id=ifelse(data_type=='SAT average score',446,439),
         subject=ifelse(data_type_subject=='avg_sat_math_score','Math',
                        ifelse(data_type_subject=='avg_sat_reading_score','Reading','Composite')),
         cohort_count=ifelse(data_type=='SAT average score',took_sat_n,graduates_n)) %>% 
  select(
    year, 
    data_type,
    data_type_id,
    entity_type,
    corp_name,
    state_id,
    subject, grade, breakdown, 
    cohort_count,
    value)

#check you didn't drop anything you didn't mean to
sum(sat_district$Year=="2017-18")-1==length(unique(clean_sat_district$state_id))

write_delim(clean_sat_district, "sat_district.txt", delim = "\t")

clean_sat_district %>% 
  group_by(year, entity_type, data_type_id, state_id, breakdown, subject, grade) %>% 
  summarize(count = n()) %>% 
  filter(count > 1)

#SCHOOL
sat_school <- read_xlsx("sat-corporation-and-school.xlsx", sheet = "School", col_names = TRUE, col_types = "text", na = "***")

clean_sat_school <- sat_school %>%
  clean_names() %>%
  filter(year=='2017-18',
         corp_id!='9625') %>%
  mutate(entity_type = 'school',
         year = 2018,
         grade = 'All',
         breakdown = 'All Students') %>%
  rename(state_id = 'sch_id') %>%
  pivot_longer(
    cols = c(
      "percent_graduates_taking_sat",
      "avg_composite_math_and_verbal","avg_sat_math_score","avg_sat_reading_score"),
    names_to = 'data_type_subject', values_to = 'value') %>%
  mutate(data_type=ifelse(str_detect(data_type_subject,regex('^avg_.*')),'SAT average score','SAT participation'),
         data_type_id=ifelse(data_type=='SAT average score',446,439),
         subject=ifelse(data_type_subject=='avg_sat_math_score','Math',
                        ifelse(data_type_subject=='avg_sat_reading_score','Reading','Composite')),
         cohort_count=ifelse(data_type=='SAT average score',took_sat_n,graduates_n)) %>% 
  select(
    year, 
    data_type,
    data_type_id,
    entity_type,
    corp_id,
    corp_name,
    state_id,
    school_name,
    subject, grade, breakdown, 
    cohort_count,
    value)

#check you didn't drop anything you didn't mean to
sum(sat_school$Year=="2017-18")-1==length(unique(clean_sat_school$state_id))

clean_sat_school %>% 
  group_by(year, entity_type, data_type_id, state_id, breakdown, subject, grade) %>% 
  summarize(count = n()) %>% 
  filter(count > 1)

write_delim(clean_sat_school, "sat_school.txt", delim = "\t")

#PS
#read in crosswalk
crosswalk <- read_delim("IN_crosswalk_districtschool2.csv", delim = ",", col_names = TRUE, col_types = cols(.default = "c"))

clean_crosswalk <- crosswalk %>%
  clean_names() # %>%
#  filter(xor((geo_type=='Corporation' & entity_level=='district'),(geo_type=='School' & entity_level=='school')))

#ENROLLMENT
ps_enrollment <- read_xlsx("2019 College Readiness Dataset - 2017 Cohort.xlsx", sheet = 'Data', col_names = TRUE, col_types = "text", na = c("***","NULL"))

clean_ps_enrollment <- ps_enrollment %>%
  clean_names() %>%
  rename(name=location,
         breakdown=breakout) %>%
  filter(!str_detect(breakdown, '< 800|<12|<2.0|1000-1199|12 to 23.75|1200-1600|2.0 to 2.5|2.6 to 3.0|21st Century Scholar|24 to 29.75|3.1 to 3.5|3.6 to 4.0|30 or more|800-999|Arts and Humanities|Associate|Award of at least 1 but less than 2 academic years|Award of less than 1 academic year|Bachelor\'s|Ball State University|Both Math and English/Language Arts|Business and Communication|Core 40|Did Not Earn Dual Credit from an Indiana Public College|Did Not Enroll In College|Did Not Take an AP Test|Earned Dual Credit from an Indiana Public College|Education|English/Language Arts Only|Full-Time|General|Graduated with Waiver|Graduated without Waiver|Health|Honors|Indiana Private College \\(for-profit\\)|Indiana Private College \\(non-profit\\)|Indiana Public College|Indiana State University|Indiana State-Affiliated Public|Indiana University-Bloomington|Indiana University-East|Indiana University-Kokomo|Indiana University-Northwest|Indiana University-Purdue University-Indianapolis|Indiana University-South Bend|Indiana University-Southeast|Ivy Tech Community College|Math Only|No Remediation|No SAT data|Non 21st Century Scholar|Non-degree Granting School|Other|Out-of-State Private College \\(for-profit\\)|Out-of-State Private College \\(non-profit\\)|Out-of-State Public College|Part-Time|Purdue University-Fort Wayne|Purdue University-Northwest|Purdue University-Polytechnic Statewide|Purdue University-West Lafayette|Remediation|Science, Technology, Engineering, and Math \\(STEM\\)|Social and Behavioral Sciences and Human Services|Took and Passed an AP Test|Took but Did Not Pass an AP Test|Trades|Unclassified undergraduate|Undecided|University of Southern Indiana|Vincennes University')) %>%
  mutate(year = 2018,
         grade = NA) %>%
  mutate(overall_college_enroll=(as.numeric(enr_college_n)/as.numeric(hs_grad_n))*100,
         in_state_college_enroll=(as.numeric(enr_in_pub_college_n)/as.numeric(hs_grad_n))*100,
         college_remediation=(as.numeric(need_remed_n)/as.numeric(enr_in_pub_college_n))*100) %>%
  pivot_longer(cols=c(overall_college_enroll,in_state_college_enroll,college_remediation),names_to = 'data_type',values_to = 'value') %>%
  mutate(value=str_remove_all(as.character(value)," "),
         data_type_id=ifelse(data_type=='overall_college_enroll',474,
                             ifelse(data_type=='in_state_college_enroll',450,413)),
         cohort_count=ifelse(data_type=='college_remediation',enr_in_pub_college_n,hs_grad_n),
         subject=ifelse(data_type=='college_remediation','Any Subject',NA)) %>%
  filter(geo_type!='County') %>%
  mutate(entity_type=ifelse(geo_type=='Corporation','district',tolower(geo_type))) %>%
  select(
    year,
    entity_type,
    name,
    breakdown,
    data_type_id,
    data_type,grade,subject,
    cohort_count,
    value
  )

#check you didn't drop anything you didn't mean to
no_county <- subset(ps_enrollment,ps_enrollment$GeoType!='County')
length(unique(no_county$Location))==length(unique(clean_ps_enrollment$name))

dupes <- clean_ps_enrollment %>% 
  group_by(year, entity_type, data_type, name, breakdown, subject, grade) %>% 
  summarize(count = n()) %>% 
  filter(count > 1)

#crosswalk ps enrollment
crosswalked_ps_enroll <- left_join(clean_ps_enrollment,clean_crosswalk,by=c("name"="location"))

clean_crosswalked_ps_enroll <- crosswalked_ps_enroll %>%
  mutate(state_id=ifelse(entity_type=='state','state',state_id)) %>%
  filter(!(str_detect(name,'Anderson Christian School|Archdiocese of Indianapolis|Bais Yaakov High School of Indiana|Bethany Christian School|Bethesda Christian School|Blackhawk Christian Mdl/High Sch|Calumet Christian School|Calvary Christian School|Central Christian Academy|Christian Academy of Indiana|Christian Academy of Madison|Clinton Christian School|Colonial Christian School|Columbus Christian School Inc|Community Baptist Christian Sch|Cornerstone Baptist Academy|Cornerstone College Prep Sch|Covenant Christian High School|Crosspointe Christian Academy|Crossroad/Ft Wayne Children\'s Home|Delaware Christian Academy|Diocese of Fort Wayne - South Bend|Elkhart Christian Academy|Eman Schools|Evansville Day School|Faith Christian School|Fishers Christian Academy|Grace Christian Academy Inc|Granger Christian School|Greenwood Christian Academy|Heritage Christian School|Heritage Hall Christian School|Horizon Christian Academy|Horizon Christian Academy 3|Horizon Christian School|Howe School|Indiana Academy|Indiana Christian Academy|International Sch of IN HS \\(9-12\\)|James E Davis School|Jay County Christian Academy|Kingdom Academy of Bluffton Inc|Lakeland Christian Academy|Lakeview Christian School Inc|Lakewood Park Christian School|Liberty Christian School|Lighthouse Christian Academy|Midwest Elite Prep Acad Inc|MTI School of Knowledge|New Vision Christian Academy|Paddock View Residential Center|Pinnacle School|Portage Christian School|Richmond Academy|Seymour Christian Academy|Shults-Lewis Child & Family Srvs|Southwest IN Regional Youth Vlg|Suburban Christian School|T.R.O.Y. Center|Tabernacle Christian School|The Crossing Educational Center|The Independence Academy|The King\'s Academy|Traders Point Christian Academy|Transitions Academy|Trinity Christian School|Trinity School At Greenlawn|University High School of Indiana|Victory Christian Academy') & entity_type=='district'),
         !(str_detect(name,'Crossroad/Ft Wayne Children\'s Home-Fort Wayne|Delaware Christian Academy-47303|Transitions Academy-46240') & entity_type=='school')) %>%
  select(
    year,
    entity_type,
    name,
    state_id,
    data_type,
    data_type_id,
    breakdown,grade,subject,
    cohort_count,
    value
  )

dupes <- clean_crosswalked_ps_enroll %>% 
  filter(!is.na(value)) %>%
  group_by(year, entity_type, name, data_type, state_id, breakdown, subject, grade) %>% 
  summarize(count = n()) %>% 
  filter(count > 1)

na_state_ids <- clean_crosswalked_ps_enroll %>% filter(!is.na(value),is.na(state_id))
investigate <- unique(na_state_ids[c("entity_type", "name")])

write_delim(clean_crosswalked_ps_enroll, "ps_enroll_remed_final.txt", delim = "\t")

#PERSISTENCE
ps_persistence <- read_xlsx("2019 College Readiness Dataset - Prior Cohorts (2014 - 2016).xlsx", sheet = 'Data', col_names = TRUE, col_types = "text", na = c("***","NULL"))

clean_ps_persistence <- ps_persistence %>%
  clean_names() %>%
  rename(name=location,
         breakdown=breakout,
         cohort_count=enr_in_pub_college_n) %>%
  filter(!str_detect(breakdown, '< 800|<12|<2.0|1000-1199|12 to 23.75|1200-1600|2.0 to 2.5|2.6 to 3.0|21st Century Scholar|24 to 29.75|3.1 to 3.5|3.6 to 4.0|30 or more|800-999|Arts and Humanities|Associate|Award of at least 1 but less than 2 academic years|Award of less than 1 academic year|Bachelor\'s|Ball State University|Both Math and English/Language Arts|Business and Communication|Core 40|Did Not Earn Dual Credit from an Indiana Public College|Did Not Enroll In College|Did Not Take an AP Test|Earned Dual Credit from an Indiana Public College|Education|English/Language Arts Only|Full-Time|General|Graduated with Waiver|Graduated without Waiver|Health|Honors|Indiana Private College \\(for-profit\\)|Indiana Private College \\(non-profit\\)|Indiana Public College|Indiana State University|Indiana State-Affiliated Public|Indiana University-Bloomington|Indiana University-East|Indiana University-Kokomo|Indiana University-Northwest|Indiana University-Purdue University-Indianapolis|Indiana University-South Bend|Indiana University-Southeast|Ivy Tech Community College|Math Only|No Remediation|No SAT data|Non 21st Century Scholar|Non-degree Granting School|Other|Out-of-State Private College \\(for-profit\\)|Out-of-State Private College \\(non-profit\\)|Out-of-State Public College|Part-Time|Purdue University-Fort Wayne|Purdue University-Northwest|Purdue University-Polytechnic Statewide|Purdue University-West Lafayette|Remediation|Science, Technology, Engineering, and Math \\(STEM\\)|Social and Behavioral Sciences and Human Services|Took and Passed an AP Test|Took but Did Not Pass an AP Test|Trades|Unclassified undergraduate|Undecided|University of Southern Indiana|Vincennes University'),
         cohort=="2016",
         geo_type!='County') %>%
  mutate(year = 2018,
         data_type = 'college persistence',
         data_type_id = 409,
         grade = NA,
         subject = NA,
         entity_type=ifelse(geo_type=='Corporation','district',tolower(geo_type)),
         value=(as.numeric(persist_n)/as.numeric(cohort_count))*100) %>%
  select(
    year,
    entity_type,
    name,
    breakdown,
    data_type_id,
    data_type,grade,subject,
    cohort_count,
    value
  )

crosswalked_ps_persist <- left_join(clean_ps_persistence,clean_crosswalk,by=c("name"="location"))

clean_crosswalked_ps_persist <- crosswalked_ps_persist %>%
  mutate(state_id=ifelse(entity_type=='state','state',state_id)) %>%
  filter(!(str_detect(name,'Anderson Christian School|Archdiocese of Indianapolis|Bais Yaakov High School of Indiana|Bethany Christian School|Bethesda Christian School|Blackhawk Christian Mdl/High Sch|Calumet Christian School|Calvary Christian School|Central Christian Academy|Christian Academy of Indiana|Christian Academy of Madison|Clinton Christian School|Colonial Christian School|Columbus Christian School Inc|Community Baptist Christian Sch|Cornerstone Baptist Academy|Cornerstone College Prep Sch|Covenant Christian High School|Crosspointe Christian Academy|Crossroad/Ft Wayne Children\'s Home|Delaware Christian Academy|Diocese of Fort Wayne - South Bend|Elkhart Christian Academy|Eman Schools|Evansville Day School|Faith Christian School|Fishers Christian Academy|Grace Christian Academy Inc|Granger Christian School|Greenwood Christian Academy|Heritage Christian School|Heritage Hall Christian School|Horizon Christian Academy|Horizon Christian Academy 3|Horizon Christian School|Howe School|Indiana Academy|Indiana Christian Academy|International Sch of IN HS \\(9-12\\)|James E Davis School|Jay County Christian Academy|Kingdom Academy of Bluffton Inc|Lakeland Christian Academy|Lakeview Christian School Inc|Lakewood Park Christian School|Liberty Christian School|Lighthouse Christian Academy|Midwest Elite Prep Acad Inc|MTI School of Knowledge|New Vision Christian Academy|Paddock View Residential Center|Pinnacle School|Portage Christian School|Richmond Academy|Seymour Christian Academy|Shults-Lewis Child & Family Srvs|Southwest IN Regional Youth Vlg|Suburban Christian School|T.R.O.Y. Center|Tabernacle Christian School|The Crossing Educational Center|The Independence Academy|The King\'s Academy|Traders Point Christian Academy|Transitions Academy|Trinity Christian School|Trinity School At Greenlawn|University High School of Indiana|Victory Christian Academy') & entity_type=='district'),
         !(str_detect(name,'Crossroad/Ft Wayne Children\'s Home-Fort Wayne|Delaware Christian Academy-47303|Transitions Academy-46240') & entity_type=='school')) %>%
  select(
    year,
    entity_type,
    name,
    state_id,
    data_type,
    data_type_id,
    breakdown,grade,subject,
    cohort_count,
    value
  )

dupes <- clean_crosswalked_ps_persist %>% 
  filter(!is.na(value)) %>%
  group_by(year, entity_type, name, data_type, state_id, breakdown, subject, grade) %>% 
  summarize(count = n()) %>% 
  filter(count > 1)

na_state_ids <- clean_crosswalked_ps_persist %>% filter(!is.na(value),is.na(state_id))
investigate <- unique(na_state_ids[c("entity_type", "name")])

write_delim(clean_crosswalked_ps_persist, "ps_persist_final.txt", delim = "\t")

#QA
data_frames <- list(clean_act_district,clean_act_school,clean_state_disagg,clean_district_disagg,clean_public_school_disagg,clean_private_school_disagg,clean_sat_district,clean_sat_school)
#data_frames <- list(clean_crosswalked_ps_enroll %>% mutate(value=as.numeric(value)),clean_crosswalked_ps_persist)
data <- bind_rows(data_frames)


qa <- data %>%
  filter(!is.na(value))

qa_entity <- qa %>% 
  group_by(data_type_id, entity_type, ) %>% 
  summarize(count = n())

qa_total <- qa %>% 
  group_by(data_type_id) %>% 
  summarize(count = n())

qa_breakdown <- qa %>% 
  group_by(data_type_id, breakdown) %>% 
  summarize(count = n())

qa_subject <- qa %>% 
  group_by(data_type_id, subject) %>% 
  summarize(count = n())



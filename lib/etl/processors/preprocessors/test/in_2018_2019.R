#indiana test processor of iread and ilearn
in_files <- advanced_find_files('DXT-3429')[-c(1:6)]

iread_files <- in_files[grep('iread3', in_files, perl=TRUE, value=FALSE)]

ilearn_files <- in_files[grep('ilearn|ILEARN', in_files, perl=TRUE, value=FALSE)][-c(1:3)]


#iread first because its more straightforward, each file has 3 sheets
#all students:
#year-iread3-final-corporation-and-school-results.xlsx
#these have one header you can skip 
#need file name and sheetname (sheetname is entity_type), file name has data_type and year

#subgroup data
#dist/school
#2018-iread3-final-disaggregated-report.xlsx  sheets CORP and SCHL

#2019-iread3-final-disaggregated-report.xlsx  sheets Corporation and School

#these have one header you can skip 

#state
#2018-iread3-final-statewide-student-performance.xlsx
#2019-iread3-final-statewide-student-performance.xlsx sheet Statewide
#one header you can skip, extra text at the bottom, 

#blank will be NA so skip NA
#skip  School Demographic|Public|Non-Public|*Totals may not match due to "Unknown" students|Students are counted in the above totals once regardless of how many times they attempted the test.

#things to note
#iread is data_type_id 223 grade is 3, headers are 2 rows (for demo) and skip the first 
#dif nomenclature for n tested: IREAD PASS N|IREAD PASS N* (2018/2019 state)
#and for prof bands: IREAD PASS %|IREAD Pass %|IREAD Pass%
#NA values are blank or ***

###IREAD ###
##ALL Students
#iread_files[1] for 2018 and iread_files[4] for 2019
#repair mismatched column names:

library(readxl)

excel_sheets(path = path)
iread_all_students_2018_sheets <- excel_sheets(path=iread_files[1])

iread_all_students_2018 <- dplyr::bind_rows(map(iread_all_students_2018_sheets, ~ read_xlsx(iread_files[1], na=c('', '***'), skip=1, guess_max=100000, sheet=.x, .name_repair=janitor::make_clean_names) %>% 
                                                       mutate(sheetname = .x,
                                                              filename =str_remove(iread_files[1], '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3429/raw/'),
                                                              breakdown='All Students',
                                                              year='2018',
                                                              data_type='IREAD',
                                                              entity_type=ifelse(str_detect(sheetname, 'Corporation|CORP'), 'district', 'school')))) 

#2019
iread_all_students_2019_sheets <- excel_sheets(path=iread_files[4])

iread_all_students_2019 <- dplyr::bind_rows(map(iread_all_students_2019_sheets, ~ read_xlsx(iread_files[4], na=c('', '***'), skip=1, guess_max=100000, sheet=.x, .name_repair=janitor::make_clean_names) %>% 
                                                  mutate(sheetname = .x,
                                                         filename =str_remove(iread_files[4], '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3429/raw/'),
                                                         breakdown='All Students',
                                                         year='2019',
                                                         data_type='IREAD',
                                                         entity_type=ifelse(str_detect(sheetname, 'Corporation|CORP'), 'district', 'school')))) 

iread_all_students <- dplyr::bind_rows(iread_all_students_2019, iread_all_students_2018) %>% 
  mutate(corporation_name=ifelse(is.na(corporation_name), corp_name, corporation_name)) %>% 
  rename(corporation_id=corp_id,
         school_id=sch_id,
         school_name=sch_name) %>% 
  select(-corp_name,
         -public_nonpublic)

##Student demographic
#2018 iread_files[2]
#2019 iread_files[5]
#now read in the student demographic information (first for school and districts)
iread_demo_2018_sheets <- excel_sheets(path=iread_files[2])
iread_demo_2018 <- dplyr::bind_rows(map(iread_demo_2018_sheets, ~ read_in_merged_header(iread_files[2], na_val=c('', '***'), n_skip=1, n_rows=2, sheet=.x) %>% 
                                                  mutate(sheetname = .x,
                                                         filename =str_remove(iread_files[2], '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3429/raw/'),
                                                         year='2018',
                                                         data_type='IREAD',
                                                         entity_type=ifelse(str_detect(sheetname, 'Corporation|CORP'), 'district', 'school')))) 

#2019
iread_demo_2019_sheets <- excel_sheets(path=iread_files[5])
iread_demo_2019 <- dplyr::bind_rows(map(iread_demo_2019_sheets, ~ read_in_merged_header(iread_files[5], na_val=c('', '***'), n_skip=1, n_rows=2, sheet=.x) %>% 
                                          mutate(sheetname = .x,
                                                 filename =str_remove(iread_files[5], '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3429/raw/'),
                                                 year='2019',
                                                 data_type='IREAD',
                                                 entity_type=ifelse(str_detect(sheetname, 'Corporation|CORP'), 'district', 'school')))) 

iread_demo <- dplyr::bind_rows(iread_demo_2018, iread_demo_2019) %>% 
  gather(key=tmp, value=value, contains('_IREAD')) %>% 
  separate(tmp, into=c('breakdown', 'type'), sep='_IREAD', extra='merge') %>% 
  spread(type, value) %>% 
  janitor::clean_names() %>% 
  rename(iread_pass_percent=pass_percent,
         iread_pass_n=pass_n,
         iread_test_n=test_n)

##State
#2018 iread_files[3]
#2019 iread_files[6]

iread_state_2018 <- read_xlsx(iread_files[3], na=c('', '***'), skip=1, guess_max=100000, .name_repair=janitor::make_clean_names) %>% 
  mutate(sheetname = 'Statewide',
         filename =str_remove(iread_files[3], '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3429/raw/'),
         year='2018',
         data_type='IREAD',
         entity_type='state')

iread_state_2019 <- read_xlsx(iread_files[6], na=c('', '***'), skip=1, guess_max=100000, .name_repair=janitor::make_clean_names) %>% 
  mutate(sheetname = 'Statewide',
         filename =str_remove(iread_files[6], '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3429/raw/'),
         year='2019',
         data_type='IREAD',
         entity_type='state')

iread_state <- dplyr::bind_rows(iread_state_2018, iread_state_2019) %>% 
  filter(!str_detect(student_demographic, 'School Demographic|Public|Non-Public|\\*Totals may not match due to "Unknown" students|\\*Totals may not match due to "Unknown" demographic information|Students are counted in the above totals once regardless of how many times they attempted the test.'),
         !is.na(student_demographic)) %>% 
  mutate(student_demographic=ifelse(student_demographic=='Total', 'All Students', student_demographic)) %>% 
  rename(breakdown=student_demographic) %>% 
  mutate(iread_pass_n=as.numeric(iread_pass_n),
         iread_test_n=as.numeric(iread_test_n),
         iread_pass_percent=as.numeric(iread_pass_percent))

#put it all together
iread_test <- dplyr::bind_rows(iread_all_students, iread_demo, iread_state)

iread_clean <- iread_test %>% 
  rename(number_tested=iread_pass_n,
         value=iread_pass_percent) %>% 
  mutate(grade='3',
         proficiency_band='prof_and_above',
         subject='Reading',
         state_id=ifelse(entity_type=='school', sprintf('%04s',school_id), 
                         ifelse(entity_type=='district', sprintf('%04s',corporation_id), 'state')),
         value=100*value) %>% 
    filter(!is.na(value),
           number_tested>=10) %>% 
    select(filename, 
           sheetname, 
           year, 
           data_type,
           entity_type, 
           district_id=corporation_id, district_name=corporation_name, school_id, school_name,  
           state_id,
           subject, grade, breakdown, proficiency_band, 
           number_tested,
           value)


###ILEARN
#ilearnfiles
#2019 only
#12 total files
#3 for us government (school, corp and state)
#3 for biology (school, corp and state)
#3 for subgroup data (school, corp and state)
#3 for all student data

##Subgroup 
#files ilearn[1-3]
#skip 4 rows and merge 3 for corp and school
#skip 1 and merge 2 for state
#wide by subgroup
#subject in sheetname
#number_tested wide by subject: Subject [1-2 words] Total Tested
#na blank, NA and ***
#prof bands [Subject] Proficient %




#State ilearn[3]
#sheets ELA, Math, Science and Social Studies (skip ELA & Math)
#skip student_demographic: Data Note|Scores reflect students enrolled in any combination of Indiana schools for a minimum of 162 days
#skip NA
ilearn_state_subgroup_sheets <- excel_sheets(path=ilearn_files[3])
ilearn_state_subgroup_sheets_clean <- ilearn_state_subgroup_sheets[!grepl('&', ilearn_state_subgroup_sheets, fixed=TRUE)]

ilearn_state_subgroup <- dplyr::bind_rows(map(ilearn_state_subgroup_sheets_clean, ~ read_in_merged_header(ilearn_files[3], na_val=c('', '***', 'NA'), n_rows=2, n_fill=1, sheet=.x) %>% 
                                          mutate(sheetname = .x,
                                                 filename =str_remove(ilearn_files[3], '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3429/raw/'),
                                                 year='2019',
                                                 data_type='ILEARN',
                                                 entity_type='state'))) 

#reoder column names for ease of gathering
#state has a demographic column already
ilearn_state_subgroup <- ilearn_state_subgroup %>% 
  select(year, entity_type, data_type, `Student Demographic`, sheetname, filename, 
         2:43, 49:111) 


#RUN FROM HERE
#we're going to process state first since its different
ilearn_state_subgroup_clean <- ilearn_state_subgroup %>% 
  gather(tmp, value, contains('grade')) %>% 
  separate(tmp, into=c('grade', 'other'), sep='_') %>% 
  separate(other, into=c('subject', 'measure'), sep='\r\n', extra='merge') %>% 
  mutate(measure=str_remove(measure, '\r\n'),
         grade=str_remove(grade, 'Grade ')) %>% 
  spread(measure, value) %>% 
  rename(value=`Proficient %`,
         number_tested=TotalTested) %>% 
  mutate(proficiency_band='prof_and_above',
         state_id='state',
         value=100*value) %>% 
  janitor::clean_names() %>% 
  filter(!str_detect(student_demographic, 'Data Note|Scores reflect students enrolled in any combination of Indiana schools for a minimum of 162 days'),
         !is.na(student_demographic),
         !is.na(value),
         number_tested>=10) %>% 
  mutate(student_demographic=ifelse(student_demographic=='Total', 'All Students', student_demographic)) %>% 
  rename(breakdown=student_demographic) %>% 
  select(filename,
         sheetname, 
         year, 
         data_type,
         entity_type, 
         state_id,
         subject, grade, breakdown, proficiency_band, 
         number_tested,
         value)
  
  
  
  


#District ilearn[1]
#every sheet, skip ELA & Math Socio Economic|ELA & Math Special Education|ELA & Math English Learners|ELA & Math Ethnicity
#skip 4 and merge 3

ilearn_dist_subgroup_sheets <- excel_sheets(path=ilearn_files[1])
ilearn_dist_subgroup_sheets_clean <- ilearn_dist_subgroup_sheets[!grepl('&', ilearn_dist_subgroup_sheets, fixed=TRUE)]

ilearn_dist_subgroup <- dplyr::bind_rows(map(ilearn_dist_subgroup_sheets_clean, ~ read_in_merged_header(ilearn_files[1], na_val=c('', '***', 'NA'), n_skip=4, n_rows=3, n_fill=2, sheet=.x) %>% 
                                                mutate(sheetname = .x,
                                                       filename =str_remove(ilearn_files[1], '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3429/raw/'),
                                                       year='2019',
                                                       data_type='ILEARN',
                                                       entity_type='district'))) 

#fix that has now been fixed in find_column_headers
#names(ilearn_dist_subgroup) = names(ilearn_dist_subgroup) %>% str_remove('NA_') 

#math socio economic sheet has rows way at the bottom that are school level 
#so I will read it in separtely with a special function that only reads in 370 rows not all
math_socio_fixed <- read_in_merged_header_special(ilearn_files[1], na_val=c('', '***', 'NA'), n_skip=4, n_rows=3, n_fill=2, sheet='Math Socio Economic') %>% 
  mutate(sheetname = 'Math Socio Economic',
         filename =str_remove(ilearn_files[1], '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3429/raw/'),
         year='2019',
         data_type='ILEARN',
         entity_type='district')

#take out that sheet
ilearn_dist_subgroup_fixed <- ilearn_dist_subgroup %>% 
  filter(sheetname!='Math Socio Economic')

#splice in the modified data
ilearn_dist_subgroup_math_fixed <- dplyr::bind_rows(ilearn_dist_subgroup_fixed, math_socio_fixed)

#check it worked
check_math_socio <- ilearn_dist_subgroup_math_fixed %>% filter(`Corp Name`=='Greater Clark County Schools') %>% 
  select(sheetname, `Corp Name`, `Corp ID`,contains('Math'))

#Found an issue with the ethnicity sheets having extra rows so rather than splice, im just going to remove
#because its easy to tell that they all have NA for Corp ID and Corp Name


#skip where corp name and corp id are NA

ilearn_dist_subgroup_rm_na <- ilearn_dist_subgroup_math_fixed %>% 
  filter(!(is.na(`Corp ID`) & is.na(`Corp Name`)))

#School ilearn[2]
#skip ELA & Math Socio Economic|ELA & Math Special Education|ELA & Math English Learners|ELA & Math Ethnicity
ilearn_sch_subgroup_sheets <- excel_sheets(path=ilearn_files[2])
ilearn_sch_subgroup_sheets_clean <- ilearn_sch_subgroup_sheets[!grepl('&', ilearn_sch_subgroup_sheets, fixed=TRUE)]

ilearn_sch_subgroup <- dplyr::bind_rows(map(ilearn_sch_subgroup_sheets_clean, ~ read_in_merged_header(ilearn_files[2], na_val=c('', '***', 'NA'), n_skip=4, n_rows=3, n_fill=2, sheet=.x) %>% 
                                               mutate(sheetname = .x,
                                                      filename =str_remove(ilearn_files[2], '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3429/raw/'),
                                                      year='2019',
                                                      data_type='ILEARN',
                                                      entity_type='school'))) 


#Put it all together
ilearn_dist_sch_subgroup <- dplyr::bind_rows(ilearn_sch_subgroup, ilearn_dist_subgroup_rm_na) %>% 
  select(year, 
         data_type,
         entity_type,
         sheetname, 
         filename,
         corp_id=`Corp ID`,
         corp_name=`Corp Name`,
         school_id=`School ID`,
         school_name=`School Name`,
         contains('%'),
         contains('Tested'))

ilearn_dist_sch_subgroup_gathered <- ilearn_dist_sch_subgroup %>% 
  gather(tmp, value, contains('Grade')) %>% 
  separate(tmp, into=c('grade', 'other'), sep='_', extra='merge')

#rm(ilearn_dist_sch_subgroup)

  

ilearn_dist_school_subgroup_clean <- ilearn_dist_sch_subgroup_gathered %>% 
  separate(other, into=c('breakdown', 'subject_measure'), sep='_', extra='merge') %>% 
  separate(subject_measure, into=c('subject', 'measure'), sep='\r\n', extra='merge') %>% 
  mutate(measure=str_remove(measure, '\r\n'),
         grade=str_remove(grade, 'Grade '))

#rm(ilearn_dist_sch_subgroup_gathered)


ilearn_dist_school_subgroup_clean_spread <- ilearn_dist_school_subgroup_clean %>% 
  spread(measure, value) %>% 
  rename(value=`Proficient %`,
         number_tested=TotalTested) %>% 
  filter(number_tested >=10)



#DO NOT RUN THIS#########
#solved these issues above
##################issues
issue <- ilearn_dist_school_subgroup_clean_filtered[93724:93850,]
#checks
check <- ilearn_dist_subgroup %>% filter(`Corp Name`=='Greater Clark County Schools') %>% 
  select(entity_type, `Corp Name`, `Corp ID`, filename, sheetname, contains('Math'))

check_sch <- ilearn_sch_subgroup %>% filter(`Corp Name`=='Greater Clark County Schools') %>% 
  select(entity_type, `Corp Name`, `Corp ID`, filename, sheetname, contains('Math'))



#######RUN THIS
######moving on 
ilearn_dist_school_subgroup_cleaner <- ilearn_dist_school_subgroup_clean_spread %>% 
  mutate(proficiency_band='prof_and_above',
         state_id=ifelse(entity_type=='school', sprintf('%04s',school_id), 
                         ifelse(entity_type=='district', sprintf('%04s',corp_id), 'state')),
         value=100*value) %>% 
  filter(!is.na(value),
         number_tested>=10) %>% 
  select(filename, 
         sheetname, 
         year, 
         data_type,
         entity_type, 
         state_id,
         district_id=corp_id, district_name=corp_name, school_id, school_name, 
         subject, grade, breakdown, proficiency_band, 
         number_tested,
         value)

#put together cleaned ilearn subgroup data

ilearn_subgroup <- dplyr::bind_rows(ilearn_dist_school_subgroup_cleaner, ilearn_state_subgroup_clean)

###ALL Students Sheets
#2 sheets: corp and school level (ilearn-2019-grade3-8-final-corporation.xlsx, ilearn-2019-grade3-8-final-school.xlsx)
#wide by grade, skip "Grand Total|Totals|School Totals|Corporation Total"
#skip 4 
#merge 2 headers, fill 1

#district file ilearn_files[7]
ilearn_dist_all_sheets <- excel_sheets(path=ilearn_files[7])
ilearn_dist_all_sheets_clean <- ilearn_dist_all_sheets[!grepl('&', ilearn_dist_all_sheets, fixed=TRUE)]

ilearn_dist_all <- dplyr::bind_rows(map(ilearn_dist_all_sheets_clean, ~ read_in_merged_header(ilearn_files[7], na_val=c('', '***', 'NA'), n_skip=4, n_rows=2, n_fill=1, sheet=.x) %>% 
                                                mutate(sheetname = .x,
                                                       filename =str_remove(ilearn_files[7], '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3429/raw/'),
                                                       year='2019',
                                                       data_type='ILEARN',
                                                       entity_type='district',
                                                       breakdown='All Students'))) 



#school file ilearn_files[8]
ilearn_sch_all_sheets <- excel_sheets(path=ilearn_files[8])
ilearn_sch_all_sheets_clean <- ilearn_sch_all_sheets[!grepl('&', ilearn_sch_all_sheets, fixed=TRUE)]

ilearn_sch_all <- dplyr::bind_rows(map(ilearn_sch_all_sheets_clean, ~ read_in_merged_header(ilearn_files[8], na_val=c('', '***', 'NA'), n_skip=4, n_rows=2, n_fill=1, sheet=.x) %>% 
                                          mutate(sheetname = .x,
                                                 filename =str_remove(ilearn_files[8], '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3429/raw/'),
                                                 year='2019',
                                                 data_type='ILEARN',
                                                 entity_type='school',
                                                 breakdown='All Students'))) 

ilearn_dist_sch_all <- dplyr::bind_rows(ilearn_sch_all, ilearn_dist_all) %>% 
  select(year, 
         data_type,
         entity_type,
         sheetname, 
         filename,
         corp_id=`Corp ID`,
         corp_name=`Corp Name`,
         school_id=`School ID`,
         school_name=`School Name`,
         breakdown,
         contains('%'),
         contains('Tested'),
         -contains('Corporation Total'),
         -contains('School Total'))

ilearn_dist_sch_all_clean <- ilearn_dist_sch_all %>% 
  gather(tmp, value, contains('Grade')) %>% 
  separate(tmp, into=c('grade', 'other'), sep='_', extra='merge') %>% 
  separate(other, into=c('subject', 'measure'), sep='\r\n', extra='merge') %>% 
  mutate(measure=str_remove(measure, '\r\n'),
         grade=str_remove(grade, 'Grade ')) %>% 
  spread(measure, value) %>% 
  rename(value=`Proficient %`,
         number_tested=TotalTested) %>% 
  filter(number_tested >=10,
         !is.na(value)) %>% 
  mutate(proficiency_band='prof_and_above',
         state_id=ifelse(entity_type=='school', sprintf('%04s',school_id), 
                         ifelse(entity_type=='district', sprintf('%04s',corp_id), 'state')),
         value=100*value) %>% 
  select(filename, 
         sheetname, 
         year, 
         data_type,
         entity_type, 
         state_id,
         district_id=corp_id, district_name=corp_name, school_id, school_name, 
         subject, grade, breakdown, proficiency_band, 
         number_tested,
         value)

#put together ilearn so far
ilearn_subgroup_all <- dplyr::bind_rows(ilearn_subgroup, ilearn_dist_sch_all_clean)
  
##ILEARN US government
#ilearn_files[9-11]
#school ilearn_file[10]
#dist ilearn_file[9]
#state ilearn_file[11]

#school ilearn_file[10]
#first sheet with just subject name as all student information (only 1 header but skip=6)
#other sheets have two headers with breakdown, or gender (n_skip=5, n_fill=1, n_rows=2)
ilearn_usgov_all_sch <- read_xlsx(ilearn_files[10], skip=6, sheet='US Government', na=c('', '***', 'NA'), guess_max=1000000) %>%
  mutate(sheetname = 'US Government',
         filename =str_remove(ilearn_files[10], '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3429/raw/'),
         year='2019',
         data_type='ILEARN',
         entity_type='school',
         breakdown='All Students',
         subject='US Government',
         grade='All')


#now read in other us government sheets from this file
ilearn_sch_usgov_sheets <- excel_sheets(path=ilearn_files[10])
ilearn_sch_usgov_sheets_clean <- ilearn_sch_usgov_sheets[!grepl('&', ilearn_sch_usgov_sheets, fixed=TRUE)][-1] #take away first sheet since we just read that in

#school ilearn_file[10]

ilearn_usgov_sch <- dplyr::bind_rows(map(ilearn_sch_usgov_sheets_clean, ~ read_in_merged_header(ilearn_files[10], na_val=c('', '***', 'NA'), n_skip=5, n_fill=1, n_rows=2, sheet=.x) %>% 
                                         mutate(sheetname = .x,
                                                filename =str_remove(ilearn_files[10], '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3429/raw/'),
                                                year='2019',
                                                data_type='ILEARN',
                                                entity_type='school',
                                                subject='US Government',
                                                grade='All'))) 

#District 
ilearn_usgov_all_dist <- read_xlsx(ilearn_files[9], skip=6, sheet='US Government', na=c('', '***', 'NA'), guess_max=1000000) %>%
  mutate(sheetname = 'US Government',
         filename =str_remove(ilearn_files[9], '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3429/raw/'),
         year='2019',
         data_type='ILEARN',
         entity_type='district',
         breakdown='All Students',
         subject='US Government',
         grade='All')


#now read in other us government sheets from this file
ilearn_dist_usgov_sheets <- excel_sheets(path=ilearn_files[9])
ilearn_dist_usgov_sheets_clean <- ilearn_dist_usgov_sheets[!grepl('&', ilearn_dist_usgov_sheets, fixed=TRUE)][-1] #take away first sheet since we just read that in

#dist ilearn_file[9]

ilearn_usgov_dist <- dplyr::bind_rows(map(ilearn_dist_usgov_sheets_clean, ~ read_in_merged_header(ilearn_files[9], na_val=c('', '***', 'NA'), n_skip=5, n_fill=1, n_rows=2, sheet=.x) %>% 
                                           mutate(sheetname = .x,
                                                  filename =str_remove(ilearn_files[9], '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3429/raw/'),
                                                  year='2019',
                                                  data_type='ILEARN',
                                                  entity_type='district',
                                                  subject='US Government',
                                                  grade='All'))) 

#iPut together the all students and the subgroup school and corp level data
ilearn_usgov_all <- dplyr::bind_rows(ilearn_usgov_all_dist, ilearn_usgov_all_sch) %>%
  janitor::clean_names() %>% 
  rename(value=us_gov_proficient_percent,
         number_tested=us_gov_total_tested) %>% 
  filter(number_tested >=10,
         !is.na(value)) %>% 
  mutate(proficiency_band='prof_and_above',
         state_id=ifelse(entity_type=='school', sprintf('%04s',school_id), 
                         ifelse(entity_type=='district', sprintf('%04s',corp_id), 'state')),
         value=100*value) %>% 
  select(filename, 
         sheetname, 
         year, 
         data_type,
         entity_type, 
         state_id,
         district_id=corp_id, district_name=corp_name, school_id, school_name, 
         subject, grade, breakdown, proficiency_band, 
         number_tested,
         value)
  

ilearn_usgov_sub <- dplyr::bind_rows(ilearn_usgov_dist, ilearn_usgov_sch) %>% 
  select(year, 
         data_type,
         entity_type,
         sheetname, 
         filename,
         corp_id=`Corp ID`,
         corp_name=`Corp Name`,
         school_id=`School ID`,
         school_name=`School Name`,
         subject,
         grade,
         contains('%'),
         contains('Tested')) %>% 
  gather(tmp, value, contains('\r\n')) %>% 
  separate(tmp, into=c('breakdown', 'measure'), sep='_', extra='merge') %>% 
  mutate(measure=str_remove(measure, 'US Gov\r\n'),
         measure=str_remove(measure, '\r\n')) %>% 
  spread(measure, value) %>% 
  janitor::clean_names() %>% 
  rename(value=proficient_percent, 
         number_tested=total_tested) %>% 
  filter(number_tested >=10,
         !is.na(value)) %>% 
  mutate(proficiency_band='prof_and_above',
         state_id=ifelse(entity_type=='school', sprintf('%04s',school_id), 
                         ifelse(entity_type=='district', sprintf('%04s',corp_id), 'state')),
         value=100*value) %>% 
  select(filename, 
         sheetname, 
         year, 
         data_type,
         entity_type, 
         state_id,
         district_id=corp_id, district_name=corp_name, school_id, school_name, 
         subject, grade, breakdown, proficiency_band, 
         number_tested,
         value)
  
#ilearn us gov state
#skip in Student Demographic: Data Note:The ILEARN US Government|Scores reflect students|U.S. Government Exam
#no skip rows, one header
ilearn_usgov_state <- read_xlsx(ilearn_files[11], na=c('', '***', 'NA'), guess_max=1000000) %>%
  mutate(sheetname = 'US Government',
         filename = str_remove(ilearn_files[11], '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3429/raw/'),
         year='2019',
         data_type='ILEARN',
         entity_type='state',
         subject='US Government',
         grade='All')

ilearn_usgov_state_clean <- ilearn_usgov_state %>% 
  janitor::clean_names() %>% 
  rename(value=proficient_percent,
         number_tested=total_tested,
         breakdown=student_demographic) %>% 
  filter(number_tested >=10,
         !is.na(value),
         !str_detect(breakdown, 'Data Note:The ILEARN US Government|Scores reflect students|U.S. Government Exam'),
         !is.na(breakdown)) %>% 
  mutate(proficiency_band='prof_and_above',
         state_id='state',
         value=as.numeric(value),
         number_tested=as.numeric(number_tested),
         value=100*value) %>% 
  select(filename, 
         sheetname, 
         year, 
         data_type,
         entity_type, 
         state_id,
         subject, grade, breakdown, proficiency_band, 
         number_tested,
         value)
  
  

ilearn_usgov <- dplyr::bind_rows(ilearn_usgov_sub, ilearn_usgov_all, ilearn_usgov_state_clean)
  


##ILEARN biology
#ilearn_files[4-6]
#first sheet with just subject name as all student information (only 1 header but skip=5)
#other sheets have two headers with breakdown, or gender (n_skip=4, n_fill=1, n_rows=2)

#school ilearn_files[5]

ilearn_biology_all_sch <- read_xlsx(ilearn_files[5], skip=5, sheet='Biology', na=c('', '***', 'NA'), guess_max=1000000) %>%
  mutate(sheetname = 'Biology',
         filename =str_remove(ilearn_files[5], '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3429/raw/'),
         year='2019',
         data_type='ILEARN',
         entity_type='school',
         breakdown='All Students',
         subject='Biology',
         grade='All')


#now read in other biology sheets from this file
ilearn_sch_biology_sheets <- excel_sheets(path=ilearn_files[5])
ilearn_sch_biology_sheets_clean <- ilearn_sch_biology_sheets[!grepl('&', ilearn_sch_biology_sheets, fixed=TRUE)][-1] #take away first sheet since we just read that in

#school ilearn_file[5]

ilearn_biology_sch <- dplyr::bind_rows(map(ilearn_sch_biology_sheets_clean, ~ read_in_merged_header(ilearn_files[5], na_val=c('', '***', 'NA'), n_skip=4, n_fill=1, n_rows=2, sheet=.x) %>% 
                                           mutate(sheetname = .x,
                                                  filename =str_remove(ilearn_files[5], '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3429/raw/'),
                                                  year='2019',
                                                  data_type='ILEARN',
                                                  entity_type='school',
                                                  subject='Biology',
                                                  grade='All'))) 

#District 
#ilearn_files[4]
ilearn_biology_all_dist <- read_xlsx(ilearn_files[4], skip=5, sheet='Biology', na=c('', '***', 'NA'), guess_max=1000000) %>%
  mutate(sheetname = 'Biology',
         filename =str_remove(ilearn_files[4], '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3429/raw/'),
         year='2019',
         data_type='ILEARN',
         entity_type='district',
         breakdown='All Students',
         subject='Biology',
         grade='All')


#now read in other us biologyernment sheets from this file
ilearn_dist_biology_sheets <- excel_sheets(path=ilearn_files[4])
ilearn_dist_biology_sheets_clean <- ilearn_dist_biology_sheets[!grepl('&', ilearn_dist_biology_sheets, fixed=TRUE)][-1] #take away first sheet since we just read that in

#dist ilearn_file[4]

ilearn_biology_dist <- dplyr::bind_rows(map(ilearn_dist_biology_sheets_clean, ~ read_in_merged_header(ilearn_files[4], na_val=c('', '***', 'NA'), n_skip=4, n_fill=1, n_rows=2, sheet=.x) %>% 
                                            mutate(sheetname = .x,
                                                   filename =str_remove(ilearn_files[4], '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3429/raw/'),
                                                   year='2019',
                                                   data_type='ILEARN',
                                                   entity_type='district',
                                                   subject='Biology',
                                                   grade='All'))) 

#iPut together the all students and the subgroup school and corp level data
ilearn_biology_all <- dplyr::bind_rows(ilearn_biology_all_dist, ilearn_biology_all_sch) %>%
  janitor::clean_names() %>% 
  rename(value=biology_proficient_percent,
         number_tested=biology_total_tested) %>% 
  filter(number_tested >=10,
         !is.na(value)) %>% 
  mutate(proficiency_band='prof_and_above',
         state_id=ifelse(entity_type=='school', sprintf('%04s',school_id), 
                         ifelse(entity_type=='district', sprintf('%04s',corp_id), 'state')),
         value=100*value) %>% 
  select(filename, 
         sheetname, 
         year, 
         data_type,
         entity_type, 
         state_id,
         district_id=corp_id, district_name=corp_name, school_id, school_name, 
         subject, grade, breakdown, proficiency_band, 
         number_tested,
         value)


ilearn_biology_sub <- dplyr::bind_rows(ilearn_biology_dist, ilearn_biology_sch) %>% 
  select(year, 
         data_type,
         entity_type,
         sheetname, 
         filename,
         corp_id=`Corp ID`,
         corp_name=`Corp Name`,
         school_id=`School ID`,
         school_name=`School Name`,
         subject,
         grade,
         contains('%'),
         contains('Tested')) %>% 
  gather(tmp, value, contains('\r\n')) %>% 
  separate(tmp, into=c('breakdown', 'measure'), sep='_', extra='merge') %>% 
  mutate(measure=str_remove(measure, 'Biology\r\n'),
         measure=str_remove(measure, '\r\n')) %>% 
  spread(measure, value) %>% 
  janitor::clean_names() %>% 
  rename(value=proficient_percent, 
         number_tested=total_tested) %>% 
  filter(number_tested >=10,
         !is.na(value)) %>% 
  mutate(proficiency_band='prof_and_above',
         state_id=ifelse(entity_type=='school', sprintf('%04s',school_id), 
                         ifelse(entity_type=='district', sprintf('%04s',corp_id), 'state')),
         value=100*value) %>% 
  select(filename, 
         sheetname, 
         year, 
         data_type,
         entity_type, 
         state_id,
         district_id=corp_id, district_name=corp_name, school_id, school_name, 
         subject, grade, breakdown, proficiency_band, 
         number_tested,
         value)

#ilearn us biology state
#skip in Student Demographic: Data Note:|Scores reflect students|Biology Exam
#no skip rows, one header
ilearn_biology_state <- read_xlsx(ilearn_files[6], na=c('', '***', 'NA'), guess_max=1000000) %>%
  mutate(sheetname = 'Biology State',
         filename = str_remove(ilearn_files[6], '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3429/raw/'),
         year='2019',
         data_type='ILEARN',
         entity_type='state',
         subject='Biology',
         grade='All')

ilearn_biology_state_clean <- ilearn_biology_state %>% 
  janitor::clean_names() %>% 
  rename(value=science_proficient_percent,
         number_tested=science_total_tested,
         breakdown=student_demographic) %>% 
  filter(number_tested >=10,
         !is.na(value),
         !str_detect(breakdown, 'Data Note:|Scores reflect students|Biology Exam'),
         !is.na(breakdown)) %>% 
  mutate(proficiency_band='prof_and_above',
         state_id='state',
         value=as.numeric(value),
         number_tested=as.numeric(number_tested),
         value=100*value) %>% 
  select(filename, 
         sheetname, 
         year, 
         data_type,
         entity_type, 
         state_id,
         subject, grade, breakdown, proficiency_band, 
         number_tested,
         value)



ilearn_biology <- dplyr::bind_rows(ilearn_biology_sub, ilearn_biology_all, ilearn_biology_state_clean)


#put together all of the ilearn files finally

ilearn_clean <- dplyr::bind_rows(ilearn_biology, ilearn_usgov, ilearn_subgroup_all)

check <- ilearn_clean %>% group_by(subject, entity_type, breakdown) %>% summarise(count=n())


files_sheets <- ilearn_clean %>% group_by(filename, sheetname) %>% summarise(count=n())

files_sheets_iread <- iread_clean %>% group_by(filename, sheetname) %>% summarise(count=n())

in_iread_ilearn <- dplyr::bind_rows(iread_clean, ilearn_clean)


file_subgroups <- in_iread_ilearn %>% group_by(filename, sheetname, breakdown) %>% summarise(count=n())

counts_qa(in_iread_ilearn)


#write out files
write_delim(iread_clean, 'Documents/Test_Load/in/iread_2018_2019.txt', delim='\t')

write_delim(ilearn_clean, 'Documents/Test_Load/in/ilearn_2019.txt', delim='\t')


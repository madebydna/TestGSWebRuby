#in istep preprocessing
in_istep_files <- advanced_find_files('DXT-3542')[-c(1:6)]


#IStep info: all 2019 is grade 10

#Istep categories:


#All Students 
subgroup_files <- in_istep_files[grep('FRL|disaggregated', in_istep_files, perl=TRUE, value=FALSE)]

all_students_files <- setdiff(in_istep_files, subgroup_files)

path <- '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3542/raw/'

##School/Corporation
#school
##grade 3-8
# istep-2018-grade3-8-final-school.xlsx, sheet Spring 2018 
#2 headers 1 to fill: grade info in column header (merged)


##grade 10
# istep-2018-grade10-final-school.xlsx, sheet Spring 2018
#2 headers 1 to fill: grade 10 in column header (merged)


#corporation 
##grade 3-8
# istep-2018-grade3-8-final-corporation.xlsx, sheet Spring 2018
#2 headers 1 to fill: grade info in column header (merged)

##grade 10 
# istep-2018-grade10-final-corporation.xlsx, sheet Spring 2018

#we can handle all of these in one because they are similar (grade in column header, one sheet like Spring 2018 or Spring 2019)

sch_dist_all_files <- all_students_files[grep('final-school|final-corporation', all_students_files, perl=TRUE, value=FALSE)]

sch_dist_all_data <- sch_dist_all_files %>% 
  map_df(function(file) {
    file %>% 
      excel_sheets() %>% 
      map_df(
        ~ read_in_merged_header(file, na_val=c("***", '', 'NA'), n_rows=2, n_fill=1, sheet=.x) %>% 
          mutate(sheetname = .x,
                 filename = str_remove(file, '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3542/raw/'),
                 breakdown='All Students',
                 entity_type=ifelse(str_detect(filename, 'corporation'), 'district', 'school'),
                 data_type='ISTEP+'))
  })

sch_dist_all_data %>% group_by(filename, sheetname) %>% summarise(count=n())
#its all there buddy

#process data
sch_dist_all_clean <- sch_dist_all_data %>% 
  select(-contains('Both'),
         -contains('Pass N'),
         -contains('School Total'),
         -contains('Corporation Total')) %>% 
  mutate(year=str_extract(sheetname, '[0-9]{4}')) %>% 
  gather(info, value, contains('Grade')) %>% 
  separate(info, c('grade', 'sub_measure'), sep='_') %>% 
  separate(sub_measure, c('subject', 'measure'), sep='\r\n', extra='merge') %>% 
  mutate(measure=str_remove(measure, '\r\n'),
         subject=trimws(subject, which='right'),
         grade=str_remove(grade, 'Grade '),
         proficiency_band='prof and above',
         state_id=ifelse(entity_type=='school', sprintf('%04s',`School ID`), 
                         ifelse(entity_type=='district', sprintf('%03s',`Corp ID`), 'state'))) %>% 
  spread(measure, value, convert=TRUE) %>% 
  select(filename, 
         sheetname, 
         year, 
         data_type,
         entity_type, 
         district_id=`Corp ID`, district_name=`Corp Name`, school_id=`School ID`, school_name=`School Name`,  
         state_id,
         subject, grade, breakdown, proficiency_band, 
         number_tested=`Test N`,
         value=`Percent Pass`)


##State
#can read in togther: 2 headers one merged no skip
all_students_state_files <- all_students_files[grep('statewide', all_students_files, perl=TRUE, value=FALSE)]
##grade 3-8
# istep-2018-grade3-8-final-statewide-summary
#have older years as column headers skip grand total row
#long by grade
#sheets for subjects ELA, Math, Social Studies, Science

##grade 10
# istep-2019-grade10-final-statewide-summary.xlsx 
# istep-2018-grade10-final-statewide-summary.xlsx
#have older years as column headers skip grand total row
#long by grade
#sheets for each subject ELA, Math, Science


#trying to read in by file and sheetname

state_all_data <- all_students_state_files %>% 
  map_df(function(file) {
    file %>% 
      excel_sheets() %>% 
      map_df(
        ~ read_in_merged_header(file, na_val=c("***", '', 'NA'), n_rows=2, n_fill=1, sheet=.x) %>% 
          mutate(sheetname = .x,
                 filename = str_remove(file, '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3542/raw/'),
                 breakdown='All Students',
                 entity_type='State',
                 data_type='ISTEP+'))
  })

#check it all got read in
state_all_data %>% group_by(filename, sheetname) %>% summarise(count=n()) #its all there

state_all_clean <- state_all_data %>% 
  select(-contains('2016-2017'),
         -contains('Both'),
         -contains('Pass N')) %>% 
  filter(sheetname!='Both',
         Statewide!='Grand Total') %>% 
  mutate(year=str_extract(filename, '[0-9]{4}'),
         grade=str_remove(Statewide, 'Grade ')) %>% 
  gather(info, value, contains('-'), convert=TRUE) %>% 
  separate(info, c('col_year', 'sub_measure'), sep='_') %>% 
  separate(sub_measure, c('subject', 'measure'), sep='\r\n', extra='merge') %>% 
  mutate(measure=str_remove(measure, '\r\n'),
         subject=trimws(subject, which='right'),
         state_id='state',
         proficiency_band='prof and above') %>% 
  filter(!(year=='2019' & col_year == '2017-2018'),
         !(year=='2018' & col_year == '2018-2019'),
         !is.na(value)) %>% 
  spread(measure, value, convert=TRUE) %>% 
  select(filename, 
         sheetname, 
         year, 
         data_type,
         entity_type, 
         state_id,
         subject, grade, breakdown, proficiency_band, 
         number_tested=`Test N`,
         value=`Pass %`)
  

state_all_clean %>% group_by(filename, sheetname) %>% summarise(count=n())


##exceptions
# istep-2018-grade10-final-science.xlsx 
#sheet 2018_Science_School school data
#sheet 2018_Science_Corp corporation data 

# istep-2018-grade3-8-final-science-and-social-studies.xls
#sheets 2018_Science_School, 2018_Social_Studies_School,2018_Science_Corp, 2018 Social_Studies_Corp

#has both district and school in sheetname, subject in sheetname, only grades 4,6 for science and 5,7 for social studies
#skip Totals column
#2 headers, fill 1
scisoci_files <- all_students_files[grep('science', all_students_files, perl=TRUE, value=FALSE)]


scisoc_all_data <- scisoci_files %>% 
  map_df(function(file) {
    file %>% 
      excel_sheets() %>% 
      map_df(
        ~ read_in_merged_header(file, na_val=c("***", '', 'NA'), n_rows=2, n_fill=1, sheet=.x) %>% 
          mutate(sheetname = .x,
                 filename = str_remove(file, '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3542/raw/'),
                 breakdown='All Students',
                 entity_type=ifelse(str_detect(sheetname, 'Corp'), 'district', 'school'),
                 data_type='ISTEP+'))
  })

scisoc_all_data %>% group_by(filename, sheetname) %>% summarise(count=n()) #its all there

#process data
scisoc_all_clean <- scisoc_all_data %>% 
  select(-contains('Both'),
         -contains('Pass N'),
         -contains('Totals')) %>% 
  mutate(year=str_extract(sheetname, '[0-9]{4}'),
         subject=str_extract(sheetname, '_.*_'),
         subject=str_remove_all(subject, '_')) %>% 
  gather(info, value, contains('Grade')) %>% 
  separate(info, c('grade', 'measure'), sep='_') %>% 
  mutate(grade=str_remove(grade, 'Grade '),
         proficiency_band='prof and above',
         state_id=ifelse(entity_type=='school', sprintf('%04s',`School`), 
                         ifelse(entity_type=='district', sprintf('%03s',`Corp`), 'state'))) %>% 
  spread(measure, value, convert=TRUE) %>% 
  select(filename, 
         sheetname, 
         year, 
         data_type,
         entity_type, 
         district_id=`Corp`, district_name=`Corp Name`, school_id=`School`, school_name=`School Name`,  
         state_id,
         subject, grade, breakdown, proficiency_band, 
         number_tested=`Test N`,
         value=`Pass %`)

istep_all_data <- dplyr::bind_rows(scisoc_all_clean, state_all_clean, sch_dist_all_clean)

#process what they all need processed
istep_all_clean <- istep_all_data %>% 
  filter(number_tested >=10,
         !is.na(value)) %>% 
  mutate(value=value*100)
  


#Wide by subgroup 
#files in subgroup_files
#separate by grade
subgroup_g38_files <- subgroup_files[grep('FRL', subgroup_files, perl=TRUE, value=FALSE)][c(1:2)] #the third one is the state file

##grades 3-8
###school
#file: ISTEP 2018 Grade3-8 Final School - FRL SE ELL Ethnicity.xlsx

###corporation
#file : ISTEP 2018 Grade3-8 Final Corp - FRL SE ELL Ethnicity.xlsx
#both files
#nskip = 4
#n_rows=3, n_fill =2 
#header has grade _ breakdown _ subject  Total Tested | Proficienct %
#skip sheets with &

subgroup_g38_data <- subgroup_g38_files %>% 
  map_df(function(file) {
    file %>% 
      excel_sheets() %>% 
      map_df(
        ~ read_in_merged_header(file, na_val=c("***", '', 'NA'), n_skip=4, n_rows=3, n_fill=2, sheet=.x) %>% 
          mutate(sheetname = .x,
                 filename = str_remove(file, '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3542/raw/'),
                 entity_type=ifelse(str_detect(filename, 'Corp'), 'district', 'school'),
                 data_type='ISTEP+'))
  })

check <- subgroup_g38_data %>% group_by(filename, sheetname) %>% summarise(count=n()) # its all there

#process the data
subgroup_g38_data_clean <- subgroup_g38_data %>% 
  filter(!str_detect(sheetname, '&')) %>% 
  select(-contains('Total\r\nProficient'), 
         -contains('&')) %>% 
  mutate(year=str_extract(filename, '[0-9]{4}')) %>% 
  gather(info, value, contains('Grade')) %>% 
  separate(info, c('grade', 'breakdownsubmeasure'), sep='_', extra='merge') %>% 
  separate(breakdownsubmeasure, c('breakdown', 'submeasure'), sep='_') %>% 
  separate(submeasure, c('subject', 'measure'), sep='\r\n', extra='merge') %>% 
  mutate(grade=str_remove(grade, 'Grade '),
         subject=trimws(subject, 'right'),
         proficiency_band='prof and above',
         state_id=ifelse(entity_type=='school', sprintf('%04s',`School ID`), 
                         ifelse(entity_type=='district', sprintf('%03s',`Corp ID`), 'state'))) %>% 
  spread(measure, value) 

subgroup_g38_data_cleaner <- subgroup_g38_data_clean %>% 
  select(filename, 
         sheetname, 
         year, 
         data_type,
         entity_type, 
         district_id=`Corp ID`, district_name=`Corp Name`, school_id=`School ID`, school_name=`School Name`,  
         state_id,
         subject, grade, breakdown, proficiency_band, 
         number_tested=`Total\r\nTested`,
         value=`Proficient \r\n%`) %>% 
  filter(number_tested >=10,
         !is.na(value)) %>% 
  mutate(value=value*100) 

check_after <- subgroup_g38_data_cleaner %>% group_by(filename, sheetname) %>% summarise(count=n())

## grade 10
subgroup_g10_files <- subgroup_files[grep('disaggregated', subgroup_files, perl=TRUE, value=FALSE)][c(1:2)] #last one is state
###school 
#file: istep-2019-grade10-final-school-disaggregated.xlsx

###corporation
# file: istep-2019-grade10-final-corporation-disaggregated.xlsx
#both files
#nskip = 0
# nrows = 2, n_fill=1,
#header has breakdown _ subject Test N | Pass Percent

#process these files
subgroup_g10_data <- subgroup_g10_files %>% 
  map_df(function(file) {
    file %>% 
      excel_sheets() %>% 
      map_df(
        ~ read_in_merged_header(file, na_val=c("***", '', 'NA'), n_rows=2, n_fill=1, sheet=.x) %>% 
          mutate(sheetname = .x,
                 filename = str_remove(file, '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3542/raw/'),
                 entity_type=ifelse(str_detect(filename, 'corporation'), 'district', 'school'),
                 data_type='ISTEP+'))
  })

subgroup_g10_data %>% group_by(filename, sheetname) %>% summarise(count=n()) # its all there

#process the data
subgroup_g10_data_clean <- subgroup_g10_data %>% 
  select(-contains('Pass N'),
         -contains('Both')) %>% 
  mutate(year=str_extract(filename, '[0-9]{4}'),
         grade='10') %>% 
  gather(info, value, contains('\r\n')) %>% 
  separate(info, c('breakdown', 'submeasure'), sep='_') %>% 
  separate(submeasure, c('subject', 'measure'), sep='\r\n') %>% 
  mutate(subject=trimws(subject, 'right'),
         proficiency_band='prof and above',
         state_id=ifelse(entity_type=='school', sprintf('%04s',`School ID`), 
                         ifelse(entity_type=='district', sprintf('%03s',`Corp ID`), 'state'))) %>% 
  spread(measure, value) %>% 
  select(filename, 
         sheetname, 
         year, 
         data_type,
         entity_type, 
         district_id=`Corp ID`, district_name=`Corp Name`, school_id=`School ID`, school_name=`School Name`,  
         state_id,
         subject, grade, breakdown, proficiency_band, 
         number_tested=`Test N`,
         value=`Pass Percent`) %>% 
  filter(number_tested >=10,
         !is.na(value)) %>% 
  mutate(value=value*100) 

istep_widesubgroup <- dplyr::bind_rows(subgroup_g38_data_cleaner, subgroup_g10_data_clean)

#Long by subgroup (state only)
##2018
#file: ISTEP 2018 Grade3-8 Final Statewide Summary - FRL SE ELL Ethnicity.xlsx
#n_rows=2 n_fill=1
#skip sheetnames with &
#Total row = 'All Students'
#header: grade _ subject Total Tested | Proficient %

subgroup_g38_state_file <- subgroup_files[grep('FRL', subgroup_files, perl=TRUE, value=FALSE)][c(3)]

#fast because only one file
state_subgroup_g38_data <- subgroup_g38_state_file %>% 
  map_df(function(file) {
    file %>% 
      excel_sheets() %>% 
      map_df(
        ~ read_in_merged_header(file, na_val=c("***", '', 'NA'), n_rows=2, n_fill=1, sheet=.x) %>% 
          mutate(sheetname = .x,
                 filename = str_remove(file, '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3542/raw/'),
                 entity_type='state',
                 year=2018,
                 data_type='ISTEP+'))
  })

#process data
state_subgroup_g38_data_clean <- state_subgroup_g38_data %>% 
  filter(!str_detect(sheetname, '&')) %>% 
  select(-contains('Total\r\nProficient'), 
         -contains('&')) %>% 
  gather(info, value, contains('Grade')) %>% 
  separate(info, c('grade', 'submeasure'), sep='_') %>% 
  separate(submeasure, c('subject', 'measure'), sep='\r\n', extra='merge') %>% 
  mutate(grade=str_remove(grade, 'Grade '),
         subject=trimws(subject, 'right'),
         breakdown=ifelse(str_detect(`Student Demographic`, 'Total'), 'All Students', `Student Demographic`),
         proficiency_band='prof and above',
         state_id=ifelse(entity_type=='school', sprintf('%04s',`School ID`), 
                         ifelse(entity_type=='district', sprintf('%03s',`Corp ID`), 'state'))) %>% 
  spread(measure, value) %>% 
  select(filename, 
         sheetname, 
         year, 
         data_type,
         entity_type, 
         state_id,
         subject, grade, breakdown, proficiency_band, 
         number_tested=`Total\r\nTested`,
         value=`Proficient \r\n%`) %>% 
  filter(number_tested >=10,
         !is.na(value)) %>% 
  mutate(value=value*100) 

##2019
#file: istep-2019-grade10-final-statewide-summary-disaggregated.xlsx
#nrows=1 
#header subject Test N | Pass %
#Grade 10 = "All Students"
#skip blank, and Grade Demographic rows in student demographic


subgroup_g10_state_file <- subgroup_files[grep('disaggregated', subgroup_files, perl=TRUE, value=FALSE)][c(3)]

#fast because only one file and one sheet
subgroup_g10_state_data <- subgroup_g10_state_file %>% 
  map_df(function(file) {
    file %>% 
      excel_sheets() %>% 
      map_df(
        ~ read_xlsx(file, na=c("***", '', 'NA'),  sheet=.x) %>% 
          mutate(sheetname = .x,
                 filename = str_remove(file, '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3542/raw/'),
                 entity_type='state',
                 year=2019,
                 data_type='ISTEP+'))
  })

state_subgroup_g10_data_clean <- subgroup_g10_state_data %>% 
  select(-contains('Pass N'),
         -contains('Both')) %>% 
  mutate(grade='10') %>% 
  gather(info, value, contains('\r\n')) %>% 
  separate(info, c('subject', 'measure'), sep='\r\n', extra='merge') %>% 
  mutate(subject=trimws(subject, 'right'),
         proficiency_band='prof and above',
         state_id='state',
         breakdown=ifelse(str_detect(`Student Demographic`, 'Grade 10'), 'All Students', `Student Demographic`)) %>% 
  spread(measure, value) %>% 
  select(filename, 
         sheetname, 
         year, 
         data_type,
         entity_type, 
         state_id,
         subject, grade, breakdown, proficiency_band, 
         number_tested=`Test N`,
         value=`Pass %`) %>% 
  filter(number_tested >=10,
         !is.na(value),
         !is.na(breakdown),
         !str_detect(breakdown, 'Grade Demographic')) %>% 
  mutate(value=as.numeric(value)*100,
         number_tested=as.numeric(number_tested)) #to fix scientific notation


#put together 
istep_long_subgroup <- dplyr::bind_rows(state_subgroup_g38_data_clean, state_subgroup_g10_data_clean) %>% 
  mutate(year=as.character(year))

#Put them all together: all students, long subgroup, wide subgroup

istep_data <- dplyr::bind_rows(istep_all_clean, istep_long_subgroup, istep_widesubgroup)


#read out the data
write_delim(istep_data, 'Documents/Test_Load/in/in_istep_2018_2019.txt', delim='\t')

counts_qa(istep_data)

#put together all in data to qa


in_istep_iread_ilearn <- dplyr::bind_rows(istep_data, in_iread_ilearn)

breakdowns <- in_istep_iread_ilearn %>% group_by(breakdown) %>% summarise(count=n())

prof <- in_istep_iread_ilearn %>% group_by(proficiency_band) %>% summarise(count=n())

#check output
in_output <- read_in_output('DXT-3550', 'in', 2019)


config <- read_delim(paste0('~/Documents/Test_Load/Test_Output/queue.config.','in','.', '2019','.test.1.txt'), delim=':', col_names=FALSE)

config_clean <- config %>% 
  rename(entity=X3,
         name=X15,
         state_id=X19) %>% 
  select(entity, name, state_id) %>% 
  arrange(entity)


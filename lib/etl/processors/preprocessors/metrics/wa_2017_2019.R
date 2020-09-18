#wa metrics load
wa_files <- advanced_find_files('DXT-3411')[-c(1:4)]

#read in crosswalks
wa_crosswalks <- advanced_find_files('DXT-3411', crosswalk=TRUE)[-c(1:2)]


wa_crosswalks <- wa_crosswalks %>% 
  map_df(function(file) {
    file %>% 
      excel_sheets() %>% 
      map_df(
        ~ read_xlsx(file, sheet=.x) %>% 
          janitor::clean_names() %>% 
          mutate(sheetname = .x,
                 filename = str_remove(file, '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3411/raw/crosswalk/')))
  })

wa_school_crosswalk <- wa_crosswalks %>% filter(str_detect(filename, 'school')) %>% 
  filter(!(entity_name=='Rogers High School' & state_id==3645))
wa_district_crosswalk <- wa_crosswalks %>% filter(str_detect(filename, 'district'))

test <- wa_crosswalks %>% unique()

#grad rates
wa_grad_files <- wa_files[grep('Graduation', wa_files, perl=TRUE, value=FALSE)]

wa_grad_data <- wa_grad_files %>% 
  map_df(function(file) {
    file %>% 
      map_df(
        ~ read_csv(file, na=c("")) %>% 
          janitor::clean_names() %>% 
          mutate(sheetname = .x,
                 filename = str_remove(file, '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3411/raw/'),
                 data_type='Grad Rate',
                 data_type_id=443))
  })

wa_grad_clean <- wa_grad_data %>% 
  rename(breakdown=student_group,
         year=school_year,
         cohort_count = final_cohort,
         value= graduation_rate) %>% 
  filter(!str_detect(organization_level, 'County|ESD'),
         str_detect(cohort, 'Four Year'),
         str_detect(year, '2019'),
         !str_detect(breakdown, 'Foster Care|Homeless|Migrant|Non Migrant|Non-Foster Care|Non-Homeless|Non Section 504|Section 504')
         ) %>% 
  mutate(entity_type=tolower(organization_level),
         subject=NA,
         grade=NA,
         cohort_count=str_remove(cohort_count, ','),
         cohort_count=ifelse(is.na(cohort_count), 'NULL', cohort_count),
         value=value * 100) %>% 
  filter(!is.na(value)) %>% 
  mutate(state_id=ifelse(entity_type=='school', sprintf('%04s', school_code),
                         ifelse(entity_type=='district', sprintf('%05s', district_code), 'state'))) %>% 
  select(year, 
         data_type,
         data_type_id,
         entity_type, 
         district_id=district_code, district_name, school_id=school_code, school_name,  
         state_id,
         subject, grade, breakdown, 
         cohort_count,
         value)

#enrollment 1 year
wa_enroll_files <- wa_files[grep('First_Year_Enrollment', wa_files, perl=TRUE, value=FALSE)] 


wa_enroll_data <- wa_enroll_files %>% 
  map_df(function(file) {
    file %>% 
      map_df(
        ~ read_csv(file, na=c("")) %>% 
          janitor::clean_names() %>% 
          mutate(sheetname = .x,
                 filename = str_remove(file, '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3411/raw/'),
                 data_type='One Year Enrollment',
                 data_type_id=474))
  })

wa_enroll_clean <- wa_enroll_data %>% 
  rename(breakdown=demographic_value,
         value= pct,
         district_name=district_ttl,
         school_name=school_ttl ) %>% 
  filter(str_detect(ps_enroll_level, 'Not Enrolled'),
         str_detect(cohort_type, '1yr'),
         str_detect(cohort_year_ttl, '2016'),
         !str_detect(breakdown, '<3.0|>=3.0|Bilingual|Not Bilingual|Not Section 504|Other (Redacted)|Section 504')
  ) %>% 
  mutate(entity_type=ifelse(school_name=='Statewide', 'state',
                            ifelse(school_name=='District Wide', 'district', 'school')),
         year=2017,
         subject=NA,
         grade=NA,
         cohort_count='NULL',
         value=(1-value) * 100) %>% 
  filter(!is.na(value)) %>% 
  left_join(wa_school_crosswalk, by=c('school_name'= 'entity_name')) %>% 
  left_join(wa_district_crosswalk, by = c('district_name' = 'entity_name')) %>% 
  mutate(state_id=ifelse(entity_type=='school', state_id.x,
                         ifelse(entity_type=='district', state_id.y, 'state'))) %>% 
  select(year, 
         data_type,
         data_type_id,
         entity_type, 
         district_name, school_name,  
         state_id,
         subject, grade, breakdown, 
         cohort_count,
         value)

#4 and 2 year
wa_remedial_files <- wa_files[grep('Remedial', wa_files, perl=TRUE, value=FALSE)] 


wa_remedial_data <- wa_remedial_files %>% 
  map_df(function(file) {
    file %>% 
      map_df(
        ~ read_csv(file, na=c("")) %>% 
          janitor::clean_names() %>% 
          mutate(sheetname = .x,
                 filename = str_remove(file, '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3411/raw/')))
  })

wa_remedial_clean <- wa_remedial_data %>% 
  rename(breakdown=demographic_value,
         subject= remedial_type,
         value= pct,
         district_name=district_ttl,
         school_name=school_ttl,
         data_type = ps_enroll_level) %>% 
  filter(str_detect(cohort_year_ttl, '2016'),
         !str_detect(breakdown, '<3.0|>=3.0|Bilingual|Not Bilingual|Not Section 504|Other (Redacted)|Section 504')
  ) %>% 
  mutate(entity_type=ifelse(school_name=='Statewide', 'state',
                            ifelse(school_name=='District Wide', 'district', 'school')),
         year=2017,
         grade=NA,
         cohort_count='NULL',
         value=value * 100,
         data_type_id=ifelse(data_type == '4 Year', 509,
                             ifelse(data_type == '2 Year / CTC', 508, NA)),
         data_type=ifelse(data_type == '4 Year', '4 Year Remediation',
                          ifelse(data_type == '2 Year / CTC', '2 Year Remediation', 'error'))) %>% 
  filter(!is.na(value)) %>% 
  left_join(wa_school_crosswalk, by=c('school_name'= 'entity_name')) %>% 
  left_join(wa_district_crosswalk, by = c('district_name' = 'entity_name')) %>% 
  mutate(state_id=ifelse(entity_type=='school', state_id.x,
                         ifelse(entity_type=='district', state_id.y, 'state'))) %>% 
  select(year, 
         data_type,
         data_type_id,
         entity_type, 
         district_name, school_name,  
         state_id,
         subject, grade, breakdown, 
         cohort_count,
         value)

#persistence
wa_persistence_files <- wa_files[grep('Persistence', wa_files, perl=TRUE, value=FALSE)] 


wa_persistence_data <- wa_persistence_files %>% 
  map_df(function(file) {
    file %>% 
      map_df(
        ~ read_csv(file, na=c("")) %>% 
          janitor::clean_names() %>% 
          mutate(sheetname = .x,
                 filename = str_remove(file, '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3411/raw/')))
  })

wa_persistence_clean <- wa_persistence_data %>% 
  rename(breakdown=demographic_value,
         value= pct,
         district_name=district_ttl,
         school_name=school_ttl,
         data_type = ps_enroll_level) %>% 
  filter(str_detect(persist_retain, 'Persisted'),
         str_detect(cohort_year_ttl, '2015'),
         str_detect(cohort_type, '1yr'),
         !str_detect(breakdown, '<3.0|>=3.0|Bilingual|Not Bilingual|Not Section 504|Other (Redacted)|Section 504')
  ) %>% 
  mutate(entity_type=ifelse(school_name=='Statewide', 'state',
                            ifelse(school_name=='District Wide', 'district', 'school')),
         year=2017,
         subject=NA,
         grade=NA,
         cohort_count='NULL',
         value=value * 100,
         data_type_id=ifelse(data_type == '4 Year', 488,
                             ifelse(data_type == '2 Year / CTC', 489, NA)),
         data_type=ifelse(data_type == '4 Year', '4 Year Persistence',
                             ifelse(data_type == '2 Year / CTC', '2 Year Persistence', 'error'))) %>% 
  filter(!is.na(value)) %>% 
  left_join(wa_school_crosswalk, by=c('school_name'= 'entity_name')) %>% 
  left_join(wa_district_crosswalk, by = c('district_name' = 'entity_name')) %>% 
  mutate(state_id=ifelse(entity_type=='school', state_id.x,
                         ifelse(entity_type=='district', state_id.y, 'state'))) %>% 
  select(year, 
         data_type,
         data_type_id,
         entity_type, 
         district_name, school_name,  
         state_id,
         subject, grade, breakdown, 
         cohort_count,
         value)
  

wa_data <- dplyr::bind_rows(wa_grad_clean, wa_enroll_clean, wa_remedial_clean,
                            wa_persistence_clean) %>% 
  filter(breakdown!='Other (Redacted)') %>% 
  mutate(state_id=ifelse(entity_type== 'school' & school_name=='Chief Leschi Schools' & state_id == 5549, 
                         'D10P15D10P15', 
                         ifelse(entity_type == 'district' & district_name== 'Chief Leschi Schools' & state_id == 27901,
                                'D10P15',
                                ifelse(entity_type=='school' & school_name== 'Muckleshoot Tribal School' & state_id == 1986,
                                       'D10P16D10P16',
                                       ifelse(entity_type == 'district' & district_name == 'Muckleshoot Indian Tribe' & state_id == 	17903,
                                              'D10P16',
                                              state_id))))) %>% 
  filter(!(entity_type== 'school' & school_name == 'Chief Leschi Schools(Closed)'))
#Checks to file

year_test <- wa_data %>% group_by(year, data_type) %>% summarise(count=n())


breakdown <- wa_data %>% group_by(breakdown) %>% summarise(count=n())


data_type <- wa_data %>% group_by(data_type, data_type_id) %>% summarise(count=n())

sub_data <- wa_data %>% group_by(data_type, subject) %>% summarise(count=n())

grade <-  wa_data %>% group_by(data_type, grade) %>% summarise(count=n()) 

checkvalue <- wa_data %>% group_by(value) %>% summarise(count=n())

cohort_count <- wa_data %>% group_by(cohort_count) %>% summarise(count=n())

d_entity_type <- wa_data %>% group_by(data_type, entity_type) %>% summarise(count=n())

check <- wa_data %>% 
  group_by(entity_type, year, data_type_id, state_id, breakdown, subject, breakdown, grade) %>% 
  summarise(count=n()) %>% 
  filter(count > 1)

#write out file
write_delim(wa_data, '~/Documents/Metrics_Load/wa/wa_2017_2019.txt', delim='\t')


#read in output file
wa_output <- read_in_output('DXT-3411', 'wa', 2019)
#checks to output

check <- compare_counts(wa_data, wa_output)


triple_check <- sanity_checks(wa_output)

#checks to output
#checks
breakdown_ids <- wa_output %>% group_by(breakdown, breakdown_id) %>% summarise(count=n())

breakdowns <- wa_output %>% group_by(breakdown) %>% summarise(count=n())

subject_ids <- wa_output %>% group_by(subject, subject_id) %>% summarise(count=n())

prof_ids <- wa_output %>% group_by(proficiency_band, proficiency_band_id) %>% summarise(count=n())

sub_grade <- wa_output %>% group_by(subject, grade) %>% summarise(count=n())

values <- wa_output %>% group_by(value) %>% summarise(count=n())

n_tested <- wa_output %>% group_by(cohort_count) %>% summarise(count=n())

grades <- wa_output %>% group_by(grade) %>% summarise(count=n())

sub_ent <- wa_output %>% group_by(entity_type, subject) %>% summarise(count=n())

y_profs <- wa_output %>% group_by(year, proficiency_band) %>% summarise(count=n())

y_e_profs <- wa_output %>% group_by(year, entity_type, proficiency_band) %>% summarise(count=n())


entity <- wa_output %>% group_by(entity_type) %>% summarise(count=n())  

entity_g <- wa_output %>% group_by(entity_type, grade) %>% summarise(count=n())

d_entity <- wa_output %>% group_by(data_type, entity_type) %>% summarise(count=n())

check_output <- wa_output %>% 
  group_by(entity_type, year, data_type_id, state_id, breakdown, subject, grade) %>% 
  summarise(count=n()) %>% 
  filter(count > 1)

counts_to_db(wa_output)

compare_rating_counts('wa', 'summary', '2020_08_28', 'datadev')
  


#va metrics load

va_file <- advanced_find_files('DXT-3410', load=TRUE)[-c(1:2)]


#grad rates
va_grad_files <- va_file[grep('cohort', va_file, perl=TRUE, value=FALSE)]

va_grad_data <- va_grad_files %>% 
  map_df(function(file) {
    file %>% 
      excel_sheets() %>% 
      map_df(
        ~ read_xlsx(file, na=c("<"), sheet=.x, skip=4) %>% 
          janitor::clean_names() %>% 
          mutate(sheetname = .x,
                 filename = str_remove(file, '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3410/load/'),
                 entity_type=ifelse(str_detect(filename, 'district'), 'district', ifelse(str_detect(filename, 'school'), 'school', 'state')),
                 data_type='Grad Rate'))
  })

va_grad_clean <- va_grad_data %>% 
  janitor::clean_names() %>% 
  rename(breakdown=subgroup,
         cohort_count=cohort, 
         district_id=division_number,
         district_name=division,
         school_id=school_number,
         school_name=school,
         value=virginia_on_time_graduation_rate) %>% 
  filter(!str_detect(breakdown, 'Economically Disadvantaged anytime|English Learners anytime|Homeless|Homeless anytime|Students with Disabilities anytime')) %>%
  mutate(state_id=ifelse(entity_type=='school', paste0(sprintf('%03s',district_id), sprintf('%04s',school_id)), 
                          ifelse(entity_type=='district', sprintf('%03s',district_id), 'state')),
         value=as.numeric(value),
         cohort_count=as.numeric(cohort_count),
         year=2019,
         data_type_id=443,
         subject=NA, 
         grade=NA) %>% 
  filter(!is.na(value),
         !is.na(cohort_count)) %>% 
  select(year, 
         data_type,
         entity_type, 
         district_id, district_name, school_id, school_name,  
         state_id,
         subject, grade, breakdown, 
         cohort_count,
         value)

#enrollment
#414
va_enrollment_files <- va_file[grep('enrollment', va_file, perl=TRUE, value=FALSE)]

va_enrollment_data <- va_enrollment_files %>% 
      map_df(
        ~ read_delim(.x, na=c("<"), delim='\t') %>% 
          janitor::clean_names() %>% 
          mutate(
                 sheetname='',
                 filename = str_remove(.x, '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3410/load/'),
                 entity_type=ifelse(str_detect(filename, 'district'), 'district', ifelse(str_detect(filename, 'school'), 'school', 'state')),
                 data_type='College Enrollment',
                 number_of_students_who_enrolled_in_a_4_year_public_institution_of_higher_education_ihe_within_16_months_of_earning_a_federally_recognized_high_school_diploma=as.numeric(number_of_students_who_enrolled_in_a_4_year_public_institution_of_higher_education_ihe_within_16_months_of_earning_a_federally_recognized_high_school_diploma)))

va_enrollment_data <- dplyr::bind_rows(map(va_enrollment_files, ~ read_delim(.x, na="<",  guess_max=1000000, delim='\t') %>% 
                                             mutate(filename = str_remove(.x, '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3410/load/'),
                                                    entity_type=ifelse(str_detect(filename, 'district'), 'district', ifelse(str_detect(filename, 'school'), 'school', 'state')),
                                                    data_type='College Enrollment') %>% 
                                             mutate_if(is.numeric, as.character)))

va_enrollment_clean <- va_enrollment_data %>% 
  janitor::clean_names() %>% 
  rename(breakdown=subgroup,
         cohort_count=total_number_of_students_in_the_cohort_earning_a_federally_recognized_high_school_diploma, 
         district_id=district_code,
         school_id=school_code,
         value=percent_of_students_who_enrolled_in_any_institution_of_higher_education_ihe_within_16_months_of_earning_a_federally_recognized_high_school_diploma) %>% 
  mutate(state_id=ifelse(entity_type=='school', paste0(sprintf('%03s',district_id), sprintf('%04s',school_id)), 
                         ifelse(entity_type=='district', sprintf('%03s',district_id), 'state')),
         value=as.numeric(value),
         cohort_count=as.numeric(cohort_count),
         year=2019,
         data_type_id=414,
         subject=NA,
         grade=NA) %>% 
  filter(!is.na(value),
         !is.na(cohort_count)) %>% 
  select(year, 
         data_type,
         entity_type, 
         district_id, district_name, school_id, school_name,  
         state_id,
         subject, grade, breakdown, 
         cohort_count,
         value)

#college persistance
#409
  
va_persistance_data <- read_xlsx(va_file[7], skip=6, guess_max=100000, na='<') %>% 
  mutate(filename = str_remove(va_file[7], '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-3410/load/'),
         entity_type='school',
         data_type='College Persistance',
         data_type_id=409,
         year=2018)

va_persistance_clean <- va_persistance_data %>% 
  janitor::clean_names() %>% 
  rename(breakdown=subgroup,
         cohort_count=total_number_of_students_in_cohort_who_graduated_from_high_school_with_a_federally_recognized_diploma_and_enrolled_in_a_public_ihe_and_or_private_non_profit_ihe_in_virginia_within_16_months_of_graduation, 
         district_name=division_name,
         value=percent_of_dual_enrollment_credits_excluded_in_total_count_of_credits_earned_and_earned_one_year_of_college_credit_within_two_years_of_enrollment) %>% 
  mutate(district_id=str_extract(district_name, '[0-9]{3}'),
         school_id=str_extract(school_name, '[0-9]{4}'),
         state_id=ifelse(entity_type=='school', paste0(sprintf('%03s',district_id), sprintf('%04s',school_id)), 
                         ifelse(entity_type=='district', sprintf('%03s',district_id), 'state')),
         value=as.numeric(value),
         cohort_count=as.numeric(cohort_count),
         year=2018,
         data_type_id=409,
         subject=NA,
         grade=NA) %>% 
  filter(!is.na(value),
         !is.na(cohort_count)) %>% 
  select(year, 
         data_type,
         entity_type, 
         district_id, district_name, school_id, school_name,  
         state_id,
         subject, grade, breakdown, 
         cohort_count,
         value)

va_data <- dplyr::bind_rows(va_persistance_clean, va_enrollment_clean, va_grad_clean)

#Checks to file

year_test <- va_data %>% group_by(year, data_type) %>% summarise(count=n())


breakdown <- va_data %>% group_by( breakdown) %>% summarise(count=n())


data_type <- va_data %>% group_by(data_type) %>% summarise(count=n())

sub_data <- va_data %>% group_by(data_type, subject) %>% summarise(count=n())


grade <-  va_data %>% group_by(data_type, grade) %>% summarise(count=n()) 


checkvalue <- va_data %>% group_by(value) %>% summarise(count=n())

cohort_count <- va_data %>% group_by(cohort_count) %>% summarise(count=n())

d_entity_type <- va_data %>% group_by(data_type, entity_type) %>% summarise(count=n())

#write out file
write_delim(va_data, '~/Documents/Metrics_Load/va/va_2018_2019.txt', delim='\t')

#read in output file
va_output <- read_in_output('DXT-3410', 'va', 2019)


check <- compare_counts(va_data, va_output)


triple_check <- sanity_checks(va_output)

#checks
breakdown_ids <- va_output %>% group_by(breakdown, breakdown_id) %>% summarise(count=n())

breakdowns <- va_output %>% group_by(breakdown) %>% summarise(count=n())

subject_ids <- va_output %>% group_by(subject, subject_id) %>% summarise(count=n())

data_grade <- va_output %>% group_by(data_type, grade) %>% summarise(count=n())

values <- va_output %>% group_by(value) %>% summarise(count=n())

n_tested <- va_output %>% group_by(cohort_count) %>% summarise(count=n())

entity <- va_output %>% group_by(entity_type) %>% summarise(count=n())  

d_entity <- va_output %>% group_by(data_type, entity_type) %>% summarise(count=n())


counts_to_db(va_output)

data_types <- c('college_readiness', 'summary')
compare_rating_counts('va', 'summary', '2020_07_15', 'datadev', growth=FALSE)


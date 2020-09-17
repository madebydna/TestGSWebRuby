library(readr)
library(dplyr)
library(readxl)
library(stringr)
library(janitor)
library(tidyverse)

setwd("~/Documents/Metrics_Load/in/Growth/2019")
list.files(getwd())

growth <- read_delim("in_growth_2019.txt", delim = "\t", col_names = TRUE, col_types = cols(.default = "c"))

clean_growth <- growth %>%
  clean_names() %>%
  separate(name, into=c('name','state_id'),sep="\\(",extra = 'merge') %>%
  mutate(year = 2019,
         date_valid = '2019-01-01 00:00:00',
         grade = 'All',
         cohort_count = '',
         entity_type=ifelse(entity_type=='state',entity_type,
                            ifelse(entity_type=='corporations','district',substr(entity_type,1,nchar(entity_type)-1))),
         state_id=ifelse(entity_type=='state','state',str_remove(state_id,"\\)")),
         state_id=ifelse(state_id=="Alt (8612)",'8612',
                         ifelse(state_id=="9-12 (C677)", 'C677',state_id)),
         value=str_remove(value,"%"),
         data_type_id=ifelse(grade_range=="3-8",'510',
                             ifelse(grade_range=='10','511','NA'))
  ) %>%
  filter(!str_detect(breakdown, 'Corporation|Indiana'))

write_delim(clean_growth,"IN_2019_growth_final.txt",delim="\t", col_names = TRUE)

#QA
qa <- clean_growth %>%
  filter(!is.na(value)) %>%
  filter(value!="None")

qa_entity <- qa %>% 
  group_by(entity_type, grade_range) %>% 
  summarize(count = n())

qa_toal <- qa %>% 
  group_by(grade_range) %>% 
  summarize(count = n())

qa_breakdown <- qa %>% 
  group_by(grade_range, breakdown) %>% 
  summarize(count = n())

qa_subjecxt <- qa %>% 
  group_by(grade_range, subject) %>% 
  summarize(count = n())

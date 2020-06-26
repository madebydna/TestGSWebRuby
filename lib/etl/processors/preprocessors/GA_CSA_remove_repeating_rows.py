#!/usr/bin/env python

import csv

open_act = open("ACT_HIGHEST_2019_FEB_24_2020.csv")
act_file = list(csv.reader(open_act))

open_sat = open("SAT_NEW_HIGHEST_2019_MAR_27_2020.csv")
sat_file = list(csv.reader(open_sat))

act_headers = act_file[0]
act_rows = act_file[1:]

sat_headers = sat_file[0]
sat_rows = sat_file[1:]

act_school_file = []
act_district_file = []
act_state_file = []

sat_school_file = []
sat_district_file = []
sat_state_file = []

act_state_unique_row = {}
act_district_unique_row = {}

sat_state_unique_row = {}
sat_district_unique_row = {}

for row in act_rows:
	district = row[1]
	subject = row[6]
	unique_district = row[1] + row[6]
	unique_state = subject
	act_school_file.append(row)
	if not unique_district in act_district_unique_row:
		act_district_file.append(row)
		act_district_unique_row[unique_district] = 'written'
	if not subject in act_state_unique_row:
		act_state_file.append(row)
		act_state_unique_row[subject] = 'written'

for row in sat_rows:
	district = row[1]
	subject = row[6]
	unique_district = row[1] + row[6]
	unique_state = subject
	sat_school_file.append(row)
	if not unique_district in sat_district_unique_row:
		sat_district_file.append(row)
		sat_district_unique_row[unique_district] = 'written'
	if not subject in sat_state_unique_row:
		sat_state_file.append(row)
		sat_state_unique_row[subject] = 'written'



with open('act_school_file.csv','w') as school_file:
	wr = csv.writer(school_file, dialect = 'excel')
	wr.writerow(act_headers)
	wr.writerows(act_school_file)
with open('act_district_file.csv','w') as district_file:
	wr = csv.writer(district_file, dialect = 'excel')
	wr.writerow(act_headers)
	wr.writerows(act_district_file)
with open('act_state_file.csv','w') as state_file:
	wr = csv.writer(state_file, dialect = 'excel')
	wr.writerow(act_headers)
	wr.writerows(act_state_file)

with open('sat_school_file.csv','w') as school_file:
	wr = csv.writer(school_file, dialect = 'excel')
	wr.writerow(sat_headers)
	wr.writerows(sat_school_file)
with open('sat_district_file.csv','w') as district_file:
	wr = csv.writer(district_file, dialect = 'excel')
	wr.writerow(sat_headers)
	wr.writerows(sat_district_file)
with open('sat_state_file.csv','w') as state_file:
	wr = csv.writer(state_file, dialect = 'excel')
	wr.writerow(sat_headers)
	wr.writerows(sat_state_file)

open_act.close()
open_sat.close()


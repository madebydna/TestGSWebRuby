from bs4 import BeautifulSoup
import requests
import re

entity_url = 'https://inview.doe.in.gov/entities?fields=id,name,type&lang=en'
data_url = 'https://inview.doe.in.gov/{}/{}/growth' #expects state, corporations or networks, schools, entities dict has school, state, district, network

def write_good_row(entity_type,id,name,subject,grade_range,breakdown,value):
	if str(breakdown) == name:
			breakdown = 'All Students'
	else:
		breakdown = breakdown
	full_string = str(entity_type) + '\t' + str(id) + '\t' + str(name) + '\t' + str(subject) + '\t' + str(grade_range) + '\t' + str(breakdown) + '\t' + str(value) + '\n'
	unicode_string = full_string.encode('utf-8')
	output_file.write(unicode_string)
	output_file.flush()

def write_bad_row(entity_type,id,name,subject):
	full_string = str(entity_type) + '\t' + str(id) + '\t' + str(name) + '\t' + str(subject) + '\tNA\tNA\tNA\n'
	unicode_string = full_string.encode('utf-8')
	output_file.write(unicode_string)
	output_file.flush()

def scrape_page(entity_type,id,name):
	if entity_type not in ['state','corporations','schools']:
		print "Entity type does not exist."
	else:
		url = data_url.format(entity_type,id)
		print "Scraping url for " + name + ": " + url
		response = requests.get(url)
		if response.status_code != 200:
			print "No response!"
		else:
			html = response.text
			soup = BeautifulSoup(html, 'html.parser')
			ela_growth_data_ems = soup.find(id="growth_growth_ela_ems")
			if ela_growth_data_ems:
				subject_grade = ela_growth_data_ems.find('h1').string
				match_subject = re.compile('^(.*) Grades 3-8$')
				match_grade = re.compile('^English/Language Arts Grades (.*)$')
				subject = match_subject.findall(subject_grade)[0]
				grade_range = match_grade.findall(subject_grade)[0]
				ela_data = ela_growth_data_ems.find_all(class_="col-12 mb-2 mb-md-0")
				for row in ela_data:
					breakdown = row.find('p').string
					value = row.find(class_='ml-2').string
					write_good_row(entity_type,id,name,subject,grade_range,breakdown,value)
			ela_growth_data_hs = soup.find(id="growth_growth_ela_hs")
			if ela_growth_data_hs:
				subject_grade = ela_growth_data_hs.find('h1').string
				match_subject = re.compile('^(.*) Grades 10$')
				match_grade = re.compile('^English/Language Arts Grades (.*)$')
				subject = match_subject.findall(subject_grade)[0]
				grade_range = match_grade.findall(subject_grade)[0]
				ela_data = ela_growth_data_hs.find_all(class_="col-12 mb-2 mb-md-0")
				for row in ela_data:
					breakdown = row.find('p').string
					value = row.find(class_='ml-2').string
					write_good_row(entity_type,id,name,subject,grade_range,breakdown,value)
			else:
				subject = 'English/Language Arts'
				write_bad_row(entity_type,id,name,subject)
			math_growth_data_ems = soup.find(id="growth_growth_math_ems")
			if math_growth_data_ems:
				subject_grade = math_growth_data_ems.find('h1').string
				match_subject = re.compile('^(.*) Grades 3-8$')
				match_grade = re.compile('^Mathematics Grades (.*)$')
				subject = match_subject.findall(subject_grade)[0]
				grade_range = match_grade.findall(subject_grade)[0]
				math_data = math_growth_data_ems.find_all(class_="col-12 mb-2 mb-md-0")
				for row in math_data:
					breakdown = row.find('p').string
					value = row.find(class_='ml-2').string
					write_good_row(entity_type,id,name,subject,grade_range,breakdown,value)
			math_growth_data_hs = soup.find(id="growth_growth_math_hs")
			if math_growth_data_hs:
				subject_grade = math_growth_data_hs.find('h1').string
				match_subject = re.compile('^(.*) Grade 10$')
				match_grade = re.compile('^Mathematics Grade (.*)$')
				subject = match_subject.findall(subject_grade)[0]
				grade_range = match_grade.findall(subject_grade)[0]
				math_data = math_growth_data_hs.find_all(class_="col-12 mb-2 mb-md-0")
				for row in math_data:
					breakdown = row.find('p').string
					value = row.find(class_='ml-2').string
					write_good_row(entity_type,id,name,subject,grade_range,breakdown,value)
			else:
				subject = 'Mathematics'
				write_bad_row(entity_type,id,name,subject)

print("Creating file.")
#create new file, will create if file doesn't already exist
output_file=open('in_growth_2019_growth.txt','w+')
output_file.write(u'entity_type\tstate_id\tname\tsubject\tgrade_range\tbreakdown\tvalue\n')

response = requests.get(entity_url)
entity_json = response.json()['entities']
entity_json_without_private_districts = [i for i in entity_json if not (i['type'] == 'network')]

urls_scraped = 0
for entity in entity_json_without_private_districts:
	if entity['type'] == 'state':
		entity_type = entity['type']
	elif entity['type'] == 'district':
		entity_type = 'corporations'
	else:
		entity_type = str(entity['type']) + 's'
	urls_scraped += 1
	pct = "{:.2%}".format(float(urls_scraped)/float(len(entity_json_without_private_districts)))
	print "Fetching URL {}, {}% complete".format(urls_scraped, pct)
	scrape_page(entity_type,entity['id'],entity['name'])

print "Scraper complete. Saving and closing file."
output_file.close()


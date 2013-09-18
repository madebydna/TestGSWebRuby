# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Test admin user
require 'states'


user = Admin.new
user.email = 'ssprouse@greatschools.org'
user.password = 'testrailsadmin'
user.save!
# Demo admin user
user = Admin.new
user.email = 'omega@greatschools.org'
user.password = 'omegademo'
user.save!
# Test admin user
user = Admin.new
user.email = 'mseltzer@greatschools.org'
user.password = 'railsadmin'
user.save!

# Schools
alameda_high_school = School.create!(state: 'CA', name: 'Alameda High School')
lowell_high_school = School.create!(state: 'CA', name: 'Lowell High School')
lowell_middle_school = School.create!(state: 'CA', name: 'Lowell Middle School')
page_private_school = School.create!(state: 'CA', name: 'Page Private School')

hart_middle_school = School.create!(state: 'DC', name: 'Hart Middle School')
kramer_middle_school = School.create!(state: 'DC', name: 'Kramer Middle School')
sheridan_school = School.create!(state: 'DC', name: 'Sheridan School')
maret_school = School.create!(state: 'DC', name: 'Maret School')


# Pages
overview = Page.create!(name: 'Overview')
quality = Page.create!(name: 'Quality')
details = Page.create!(name: 'Details')
reviews = Page.create!(name: 'Reviews')

#highlights = Page.create!(name: 'Highlights', parent:programs_culture)
#programs_resources = Page.create!(name: 'Programs & resources', parent:programs_culture)
#extracurriculars = Page.create!(name: 'Extracurriculars', parent: programs_culture)
#culture = Page.create!(name: 'Culture', parent: programs_culture)

# Test collections
bay_area_schools = Collection.create!(name: 'Bay Area schools')
private_schools = Collection.create!(name: 'Private schools')
dc_schools = Collection.create!(name: 'Washington dc schools')

# School collections
SchoolCollection.create!(school:alameda_high_school, collection:bay_area_schools)
SchoolCollection.create!(school:lowell_high_school, collection:bay_area_schools)
SchoolCollection.create!(school:lowell_middle_school, collection:bay_area_schools)

SchoolCollection.create!(school:page_private_school, collection:private_schools)
SchoolCollection.create!(school:sheridan_school, collection:private_schools)
SchoolCollection.create!(school:maret_school, collection:private_schools)
SchoolCollection.create!(school:maret_school, collection:dc_schools)


# Categories
school_basics = Category.create!(name: 'School basics')
programs = Category.create!(name: 'Programs')
sports = Category.create!(name: 'Sports')
arts_music = Category.create!(name: 'Arts & Music')
student_ethnicity = Category.create!(name: 'Student ethnicity', source: 'StudentEthnicity')
category_no_osp_data = Category.create!(name: 'Bogus Category w/o OSP Data', source: 'EspResponse')


# Category placements
# defaults (no collection)
CategoryPlacement.create!(
    category: student_ethnicity, page: details, position: 1, title: 'Ethnicity pie chart', layout: 'pie_chart', size: 4,
    layout_config: "{ \"columns\": \r\n  [ \r\n  \t{ \r\n    \t\"label\": \"Student ethnicity\", \r\n    \t\"hide_header\": true, \r\n    \t\"key\": \"ethnicity\" \r\n  \t}, \r\n  \t{ \r\n    \t\"label\": \"School value\", \r\n    \t\"key\": \"school_value\", \r\n    \t\"format\": \"percentage\" \r\n  \t}, \r\n  \t{ \r\n    \t\"label\": \"State value\", \r\n    \t\"key\": \"state_value\", \r\n    \t\"format\": \"percentage\" \r\n  \t} \r\n  ] \r\n}"
)
CategoryPlacement.create!(
    category: student_ethnicity, page: details, title: 'Ethnicity data', position: 2, layout: 'configured_table', size: 8,
    layout_config: "{ \"columns\": \r\n  [ \r\n  \t{ \r\n    \t\"label\": \"Student ethnicity\", \r\n    \t\"hide_header\": true, \r\n    \t\"key\": \"ethnicity\" \r\n  \t}, \r\n  \t{ \r\n    \t\"label\": \"School value\", \r\n    \t\"key\": \"school_value\", \r\n    \t\"format\": \"percentage\" \r\n  \t}, \r\n  \t{ \r\n    \t\"label\": \"State value\", \r\n    \t\"key\": \"state_value\", \r\n    \t\"format\": \"percentage\" \r\n  \t} \r\n  ] \r\n}"
)
CategoryPlacement.create!(category: school_basics, page: details, position: 3, size: 12 )
CategoryPlacement.create!(category: arts_music, page: details, position: 4, size: 6 )
CategoryPlacement.create!(category: programs, page: details, position: 5, size: 6 )

# different config for different page
CategoryPlacement.create!(
    category: student_ethnicity, page: overview, position: 5, title: 'Ethnicity pie chart', layout: 'pie_chart', size: 4,
    layout_config: "{ \"columns\": \r\n  [ \r\n  \t{ \r\n    \t\"label\": \"Student ethnicity\", \r\n    \t\"hide_header\": true, \r\n    \t\"key\": \"ethnicity\" \r\n  \t}, \r\n  \t{ \r\n    \t\"label\": \"School value\", \r\n    \t\"key\": \"school_value\", \r\n    \t\"format\": \"percentage\" \r\n  \t}, \r\n  \t{ \r\n    \t\"label\": \"State value\", \r\n    \t\"key\": \"state_value\", \r\n    \t\"format\": \"percentage\" \r\n  \t} \r\n  ] \r\n}"
)
CategoryPlacement.create!(
    category: student_ethnicity, page: overview, title: 'Ethnicity data', position: 4, layout: 'configured_table', size: 8,
    layout_config: "{ \"columns\": \r\n  [ \r\n  \t{ \r\n    \t\"label\": \"Student ethnicity\", \r\n    \t\"hide_header\": true, \r\n    \t\"key\": \"ethnicity\" \r\n  \t}, \r\n  \t{ \r\n    \t\"label\": \"School value\", \r\n    \t\"key\": \"school_value\", \r\n    \t\"format\": \"percentage\" \r\n  \t}, \r\n  \t{ \r\n    \t\"label\": \"State value\", \r\n    \t\"key\": \"state_value\", \r\n    \t\"format\": \"percentage\" \r\n  \t} \r\n  ] \r\n}"
)
CategoryPlacement.create!(category: school_basics, page: overview, position: 1, size: 6 )
CategoryPlacement.create!(category: arts_music, page: overview, position: 2, size: 6 )
CategoryPlacement.create!(category: programs, page: overview, position: 3, size: 12 )

# different config for different page
CategoryPlacement.create!(
    category: student_ethnicity, page: quality, position: 2, title: 'Ethnicity pie chart', layout: 'pie_chart', size: 4,
    layout_config: "{ \"columns\": \r\n  [ \r\n  \t{ \r\n    \t\"label\": \"Student ethnicity\", \r\n    \t\"hide_header\": true, \r\n    \t\"key\": \"ethnicity\" \r\n  \t}, \r\n  \t{ \r\n    \t\"label\": \"School value\", \r\n    \t\"key\": \"school_value\", \r\n    \t\"format\": \"percentage\" \r\n  \t}, \r\n  \t{ \r\n    \t\"label\": \"State value\", \r\n    \t\"key\": \"state_value\", \r\n    \t\"format\": \"percentage\" \r\n  \t} \r\n  ] \r\n}"
)
CategoryPlacement.create!(
    category: student_ethnicity, page: quality, title: 'Ethnicity data', position: 3, layout: 'configured_table', size: 8,
    layout_config: "{ \"columns\": \r\n  [ \r\n  \t{ \r\n    \t\"label\": \"Student ethnicity\", \r\n    \t\"hide_header\": true, \r\n    \t\"key\": \"ethnicity\" \r\n  \t}, \r\n  \t{ \r\n    \t\"label\": \"School value\", \r\n    \t\"key\": \"school_value\", \r\n    \t\"format\": \"percentage\" \r\n  \t}, \r\n  \t{ \r\n    \t\"label\": \"State value\", \r\n    \t\"key\": \"state_value\", \r\n    \t\"format\": \"percentage\" \r\n  \t} \r\n  ] \r\n}"
)
CategoryPlacement.create!(category: school_basics, page: quality, position: 1, size: 12 )
CategoryPlacement.create!(category: arts_music, page: quality, position: 4, size: 12 )
CategoryPlacement.create!(category: programs, page: quality, position: 5, size: 12 )

# different config for different page
CategoryPlacement.create!(
    category: student_ethnicity, page: reviews, position: 3, title: 'Ethnicity pie chart', layout: 'pie_chart', size: 6,
    layout_config: "{ \"columns\": \r\n  [ \r\n  \t{ \r\n    \t\"label\": \"Student ethnicity\", \r\n    \t\"hide_header\": true, \r\n    \t\"key\": \"ethnicity\" \r\n  \t}, \r\n  \t{ \r\n    \t\"label\": \"School value\", \r\n    \t\"key\": \"school_value\", \r\n    \t\"format\": \"percentage\" \r\n  \t}, \r\n  \t{ \r\n    \t\"label\": \"State value\", \r\n    \t\"key\": \"state_value\", \r\n    \t\"format\": \"percentage\" \r\n  \t} \r\n  ] \r\n}"
)
CategoryPlacement.create!(
    category: student_ethnicity, page: reviews, title: 'Ethnicity data', position: 4, layout: 'configured_table', size: 6,
    layout_config: "{ \"columns\": \r\n  [ \r\n  \t{ \r\n    \t\"label\": \"Student ethnicity\", \r\n    \t\"hide_header\": true, \r\n    \t\"key\": \"ethnicity\" \r\n  \t}, \r\n  \t{ \r\n    \t\"label\": \"School value\", \r\n    \t\"key\": \"school_value\", \r\n    \t\"format\": \"percentage\" \r\n  \t}, \r\n  \t{ \r\n    \t\"label\": \"State value\", \r\n    \t\"key\": \"state_value\", \r\n    \t\"format\": \"percentage\" \r\n  \t} \r\n  ] \r\n}"
)
CategoryPlacement.create!(category: school_basics, page: reviews, position: 5, size: 12 )
CategoryPlacement.create!(category: arts_music, page: reviews, position: 1, size: 12 )
CategoryPlacement.create!(category: programs, page: reviews, position: 2, size: 12 )


# Category data
CategoryData.create!(category: sports,response_key:'girls_sports', collection:private_schools)
CategoryData.create!(category: sports, response_key:'boys_sports', collection:private_schools)
CategoryData.create!(category: sports, response_key:'boys_sports_other', collection:private_schools)
CategoryData.create!(category: sports, response_key:'girls_sports_other', collection:private_schools)
CategoryData.create!(category: sports,response_key:'girls_sports', collection:dc_schools)
CategoryData.create!(category: sports, response_key:'boys_sports', collection:dc_schools)
CategoryData.create!(category: sports, response_key:'boys_sports_other', collection:dc_schools)
CategoryData.create!(category: sports, response_key:'girls_sports_other', collection:dc_schools)
CategoryData.create!(category: sports, response_key:'girls_sports', collection:bay_area_schools)
CategoryData.create!(category: sports, response_key:'boys_sports', collection:bay_area_schools)
CategoryData.create!(category: sports, response_key:'boys_sports_other', collection:bay_area_schools)
CategoryData.create!(category: sports, response_key:'girls_sports_other', collection:bay_area_schools)
CategoryData.create!(category: school_basics, response_key:'administrator_name')
CategoryData.create!(category: school_basics, response_key:'school_fax')
CategoryData.create!(category: school_basics, response_key:'start_time')
CategoryData.create!(category: school_basics, response_key:'end_time')

CategoryData.create!(category: arts_music, response_key:'arts_music')
CategoryData.create!(category: arts_music, response_key:'arts_performing_written')

CategoryData.create!(category: programs, response_key:'special_ed_programs')
CategoryData.create!(category: programs, response_key:'foreign_language')
CategoryData.create!(category: category_no_osp_data, response_key:'_bogus')


# steal data from dev's esp_response to populate EspResponse
=begin
schools_per_state = 4
%w(ca dc).each_with_index do |state, index|
  first = (index * schools_per_state) + 1
  last = (index+1) * schools_per_state
  query = "select * from _#{state}.esp_response where school_id >= #{first} "
  query += " and school_id <= #{last} and active=1 and response_key in (#{CategoryData.all.map{ |item| item.response_key}.to_s[1..-2]})"
  client = Mysql2::Client.new(host: 'dev.greatschools.org', username: 'service', :password => 'service')
  results = client.query(query)
  if results.count > 0
    results.each do |result|
      EspResponse.create!(
          school: School.find(result['school_id']),
          key:result['response_key'],
          value:result['response_value'],
          active:true
      )
    end
  end
end
=end

# steal data from dev's esp_response to populate EspResponse
=begin
schools_per_state = 4
%w(ca dc).each_with_index do |state, index|
  first = (index * schools_per_state) + 1
  last = (index+1) * schools_per_state
  query = "select * from _#{state}.esp_response where school_id >= #{first} "
  query += " and school_id <= #{last} and active=1 and response_key in (#{CategoryData.all.map{ |item| item.response_key}.to_s[1..-2]})"
  client = Mysql2::Client.new(host: 'dev.greatschools.org', username: 'service', :password => 'service')
  results = client.query(query)
  if results.count > 0
    results.each do |result|
      EspResponse.create!(
          school: School.find(result['school_id']),
          key:result['response_key'],
             value:result['response_value'],
             active:true
      )
    end
  end
end
=end

=begin
EspResponse.create!(school: School.find(6),key:'boy_sports',value:'tennis',active:true)
EspResponse.create!(school: School.find(6),key:'boy_sports',value:'track',active:true)
EspResponse.create!(school: School.find(6),key:'boy_sports_other',value:'swimming',active:true)
EspResponse.create!(school: School.find(6),key:'foreign_language',value:'french',active:true)
EspResponse.create!(school: School.find(6),key:'arts_music',value:'chorus',active:true)
EspResponse.create!(school: School.find(6),key:'start_time',value:'8:00',active:true)
EspResponse.create!(school: School.find(6),key:'end_time',value:'12:00',active:true)
EspResponse.create!(school: School.find(6),key:'special_ed_programs',value:'multiple',active:true)
=end


# response value - this table is used to store the keys or values and their pretty labels.

#esp response keys and their pretty labels
ResponseValue.create!(response_value: 'girls_sports',response_label:'Sports for Girls',collection:private_schools)
ResponseValue.create!(response_value: 'boys_sports',response_label:'Sports for boys',collection:private_schools)
ResponseValue.create!(response_value: 'boys_sports_other',response_label:'Other sports for boys',collection:private_schools)
ResponseValue.create!(response_value: 'girls_sports_other',response_label:'Other sports for girls',collection:private_schools)
ResponseValue.create!(response_value: 'girls_sports',response_label:'Sports for Girls',collection:bay_area_schools)
ResponseValue.create!(response_value: 'boys_sports',response_label:'Sports for boys',collection:bay_area_schools)
ResponseValue.create!(response_value: 'boys_sports_other',response_label:'Other sports for boys',collection:bay_area_schools)
ResponseValue.create!(response_value: 'girls_sports_other',response_label:'Other sports for girls',collection:bay_area_schools)
ResponseValue.create!(response_value: 'administrator_name',response_label:'School Leader\'s name')
ResponseValue.create!(response_value: 'school_fax',response_label:'Fax number')
ResponseValue.create!(response_value: 'start_time',response_label:'School start time')
ResponseValue.create!(response_value: 'end_time',response_label:'School end time')
ResponseValue.create!(response_value: 'arts_music',response_label:'Music')
ResponseValue.create!(response_value: 'arts_performing_written',response_label:'Performing arts')
ResponseValue.create!(response_value: 'special_ed_programs',response_label:'Specialized programs for specific types of special education students')
ResponseValue.create!(response_value: 'foreign_language',response_label:'Foreign languages taught')

#esp response values and their pretty labels
schools_per_state = 4
%w(ca dc).each_with_index do |state, index|
  first = (index * schools_per_state) + 1
  last = (index+1) * schools_per_state
  query = "select * from _#{state}.esp_response where school_id >= #{first} and school_id <= #{last} and response_key like '%sports%'"
  client = Mysql2::Client.new(host: 'dev.greatschools.org', username: 'service', :password => 'service')
  results = client.query(query)
  if results.count > 0
    results.each do |result|
      ResponseValue.create!(response_value:result['response_value'],response_label:result['response_value'].gsub('_',' '), collection:private_schools)
      ResponseValue.create!(response_value:result['response_value'],response_label:result['response_value'].gsub('_',' '), collection:bay_area_schools)
    end
  end
end

# census breakdown
query = 'select * from gs_schooldb.census_breakdown'
client = Mysql2::Client.new(host: 'dev.greatschools.org', username: 'service', :password => 'service')
results = client.query(query)
if results.count > 0
  results.each do |result|
    CensusBreakdown.create!(datatype_id: result['datatype_id'], description: result['description'])
  end
end

=begin
require 'states'
States.state_hash.values.each do |state|
  query = "select * _#{state}"

end
=end

SchoolCategoryData.using(alameda_high_school.state.upcase.to_sym).create!(key: 'student_ethnicity',school: alameda_high_school,school_data: {
      rows: [
            {
                ethnicity: 'Asian',
                school_value: '51',
                state_value: '11'
            },
            {
                ethnicity: 'White',
                school_value: '32',
                state_value: '27'
            },
            {
                ethnicity: 'Hispanic',
                school_value: '9',
                state_value: '51'
            },
            {
                ethnicity: 'Black',
                school_value: '6',
                state_value: '7'
            },
            {
                ethnicity: 'Hawaiian Native/Pacific Islander',
                school_value: '1',
                state_value: '1'
            },
            {
                ethnicity: 'Two or more races',
                school_value: '1',
                state_value: '3'
            },
            {
                ethnicity: 'American Indian/Alaska Native',
                school_value: '0',
                state_value: '1'
            },
        ]
    }.to_json )


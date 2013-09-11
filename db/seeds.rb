# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Test admin user
user = Admin.new
user.email = 'ssprouse@greatschools.org'
user.password = 'testrailsadmin'
user.save!
# Demo admin user
user = Admin.new
user.email = 'omega@greatschools.org'
user.password = 'omegademo'
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
programs_culture = Page.create!(name: 'Programs & culture')
highlights = Page.create!(name: 'Highlights', parent:programs_culture)
programs_resources = Page.create!(name: 'Programs & resources', parent:programs_culture)
extracurriculars = Page.create!(name: 'Extracurriculars', parent: programs_culture)
culture = Page.create!(name: 'Culture', parent: programs_culture)


# Test collections
bay_area_schools = Collection.create!(name: 'Bay Area schools')
private_schools = Collection.create!(name: 'Private schools')

# School collections
SchoolCollection.create!(school:alameda_high_school, collection:bay_area_schools)
SchoolCollection.create!(school:lowell_high_school, collection:bay_area_schools)
SchoolCollection.create!(school:lowell_middle_school, collection:bay_area_schools)

SchoolCollection.create!(school:page_private_school, collection:private_schools)
SchoolCollection.create!(school:sheridan_school, collection:private_schools)
SchoolCollection.create!(school:maret_school, collection:private_schools)


# Categories
school_basics = Category.create!(name: 'School basics')
programs = Category.create!(name: 'Programs')
sports = Category.create!(name: 'Sports')
arts_music = Category.create!(name: 'Arts & Music')
student_ethnicity = Category.create!(name: 'Student ethnicity', source: 'StudentEthnicity')


# Category placements
CategoryPlacement.create!(category: school_basics, page: programs_resources, collection: bay_area_schools, position: 1 )
CategoryPlacement.create!(category: programs, page: programs_resources, position: 2 )
CategoryPlacement.create!(category: sports, page: extracurriculars, collection: nil, position: 1 )
CategoryPlacement.create!(category: arts_music, page: extracurriculars, collection: nil, position: 2 )
CategoryPlacement.create!(category: sports, page: culture, collection: nil, position: 1 )
CategoryPlacement.create!(
    category: student_ethnicity, page: programs_resources, position: 3, layout: 'configured_table',
    layout_config: "{ \"columns\": \r\n  [ \r\n  \t{ \r\n    \t\"label\": \"Student ethnicity\", \r\n    \t\"hide_header\": true, \r\n    \t\"key\": \"ethnicity\" \r\n  \t}, \r\n  \t{ \r\n    \t\"label\": \"School value\", \r\n    \t\"key\": \"school_value\", \r\n    \t\"format\": \"percentage\" \r\n  \t}, \r\n  \t{ \r\n    \t\"label\": \"State value\", \r\n    \t\"key\": \"state_value\", \r\n    \t\"format\": \"percentage\" \r\n  \t} \r\n  ] \r\n}"
)

# Category data
CategoryData.create!(category: sports,response_key:'girls_sports', collection:private_schools)
CategoryData.create!(category: sports, response_key:'boys_sports', collection:private_schools)
CategoryData.create!(category: sports, response_key:'boys_sports_other', collection:private_schools)
CategoryData.create!(category: sports, response_key:'girls_sports_other', collection:private_schools)
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


# steal data from dev's esp_response to populate EspResponse
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


SchoolCategoryData.create!(key: 'student_ethnicity',school: alameda_high_school,school_data: {
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
    }.as_json )

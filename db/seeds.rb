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
sports = Category.create!(name: 'Sports')
arts_music = Category.create!(name: 'Arts & Music')


# Category placements
CategoryPlacement.create!(category: school_basics, page: programs_resources, collection: bay_area_schools, position: 1 )
CategoryPlacement.create!(category: sports, page: extracurriculars, collection: nil, position: 1 )
CategoryPlacement.create!(category: arts_music, page: extracurriculars, collection: nil, position: 2 )
CategoryPlacement.create!(category: sports, page: culture, collection: nil, position: 1 )


# steal data from dev's esp_response to populate SchoolCategoryData
schools_per_state = 4
%w(ca dc).each_with_index do |state, index|
  first = (index * schools_per_state) + 1
  last = (index+1) * schools_per_state
  query = "select * from _#{state}.esp_response where school_id >= #{first} and school_id <= #{last} and response_key like '%sports%'"
  client = Mysql2::Client.new(host: 'dev.greatschools.org', username: 'service', :password => 'service')
  results = client.query(query)
  if results.count > 0
    results.each do |result|
      SchoolCategoryData.create!(
          school: School.find(result['school_id']),
          key:result['response_key'],
          value:result['response_value'],
          active:true
      )
    end
  end
end


# Category data
CategoryData.create!(category:sports,response_key:'girls_sports',response_label:'Sports for Girls', collection:private_schools)
CategoryData.create!(category:sports,response_key:'boys_sports',response_label:'Sports for boys', collection:private_schools)
CategoryData.create!(category:sports,response_key:'boys_sports_other',response_label:'Other sports for boys', collection:private_schools)
CategoryData.create!(category:sports,response_key:'girls_sports_other',response_label:'Other sports for girls', collection:private_schools)
CategoryData.create!(category:sports,response_key:'girls_sports',response_label:'Sports for Girls', collection:bay_area_schools)
CategoryData.create!(category:sports,response_key:'boys_sports',response_label:'Sports for boys', collection:bay_area_schools)
CategoryData.create!(category:sports,response_key:'boys_sports_other',response_label:'Other sports for boys', collection:bay_area_schools)
CategoryData.create!(category:sports,response_key:'girls_sports_other',response_label:'Other sports for girls', collection:bay_area_schools)


# response value
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
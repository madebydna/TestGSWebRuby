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
@alameda_high_school = School.on_db(:ca).where(name: 'Alameda High School').first
@lowell_high_school = School.on_db(:ca).where(name: 'Lowell High School').first
@lowell_middle_school = School.on_db(:ca).where(name: 'Lowell Middle School').first
@page_private_school = School.on_db(:ca).where(name: 'Page Private School').first

@hart_middle_school = School.on_db(:dc).where(name: 'Hart Middle School').first
@kramer_middle_school = School.on_db(:dc).where(name: 'Kramer Middle School').first
@sheridan_school = School.on_db(:dc).where(name: 'Sheridan School').first
@maret_school = School.on_db(:dc).where(name: 'Maret School').first


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
detroit_schools = Collection.create!(name: 'Detroit schools')

# School collections
SchoolCollection.create!(school:@alameda_high_school, collection:bay_area_schools)
SchoolCollection.create!(school:@lowell_high_school, collection:bay_area_schools)

SchoolCollection.create!(school:@page_private_school, collection:private_schools)
SchoolCollection.create!(school:@sheridan_school, collection:private_schools)
SchoolCollection.create!(school:@maret_school, collection:private_schools)
SchoolCollection.create!(school:@maret_school, collection:dc_schools)


# Categories
school_basics = Category.create!(name: 'School basics', source:'esp_response')
programs = Category.create!(name: 'Programs', source:'esp_response')
sports = Category.create!(name: 'Sports', source:'esp_response')
arts_music = Category.create!(name: 'Arts & Music', source:'esp_response')
student_ethnicity = Category.create!(name: 'Student ethnicity', source: 'student_ethnicity')
category_no_osp_data = Category.create!(name: 'Bogus Category w/o OSP Data', source:'esp_response')
test_scores = Category.create!(name: 'Test scores', source: 'test_scores')
snapshot = Category.create!(name: 'Snapshot', source: 'snapshot')
details_summary = Category.create!(name: 'Details', source:'details')
dummy_category = Category.create!(name: 'Dummy', source:'dummy')


# Category placements
# defaults (no collection)
# different config for different page  - Details
CategoryPlacement.create!(category: school_basics, page: details, position: 3, size: 12 )
CategoryPlacement.create!(category: arts_music, page: details, position: 4, size: 6 )
CategoryPlacement.create!(category: programs, page: details, position: 5, size: 6 )
CategoryPlacement.create!(
    category: student_ethnicity, page: details, position: 7, title: 'Ethnicity pie chart', layout: 'pie_chart', size: 4,
    layout_config: "{ \"columns\": \r\n  [ \r\n  \t{ \r\n    \t\"label\": \"Student ethnicity\", \r\n    \t\"hide_header\": true, \r\n    \t\"key\": \"ethnicity\" \r\n  \t}, \r\n  \t{ \r\n    \t\"label\": \"School value\", \r\n    \t\"key\": \"school_value\", \r\n    \t\"format\": \"percentage\" \r\n  \t}, \r\n  \t{ \r\n    \t\"label\": \"State value\", \r\n    \t\"key\": \"state_value\", \r\n    \t\"format\": \"percentage\" \r\n  \t} \r\n  ] \r\n}"
)
CategoryPlacement.create!(
    category: student_ethnicity, page: details, title: 'Ethnicity data', position: 8, layout: 'configured_table', size: 8,
    layout_config: "{ \"columns\": \r\n  [ \r\n  \t{ \r\n    \t\"label\": \"Student ethnicity\", \r\n    \t\"hide_header\": true, \r\n    \t\"key\": \"ethnicity\" \r\n  \t}, \r\n  \t{ \r\n    \t\"label\": \"School value\", \r\n    \t\"key\": \"school_value\", \r\n    \t\"format\": \"percentage\" \r\n  \t}, \r\n  \t{ \r\n    \t\"label\": \"State value\", \r\n    \t\"key\": \"state_value\", \r\n    \t\"format\": \"percentage\" \r\n  \t} \r\n  ] \r\n}"
)


# different config for different page  - Overview
CategoryPlacement.create!(category: snapshot, page: overview, position: 1, layout: 'snapshot',
                          layout_config: "{ \"enrollment\": {\"format\": \"integer\"}}" )
CategoryPlacement.create!(category: dummy_category, layout: 'reviews_overview', title: 'Reviews Overview', page: overview, position: 3, size: 12 )
CategoryPlacement.create!(category: dummy_category, layout: 'lightbox_overview', title: 'Media Gallery', page: overview, position: 4, size: 12 )
#CategoryPlacement.create!(category: dummy_category, layout: 'details', title: 'Details', page: overview, position: 5, size: 12 )
CategoryPlacement.create!(category: details_summary, page: overview, position: 7, title: 'Details', layout: 'details')
CategoryPlacement.create!(
    category: student_ethnicity, page: overview, position: 8, title: 'Ethnicity pie chart', layout: 'pie_chart_overview', size: 12,
    layout_config: "{ \"columns\": \r\n  [ \r\n  \t{ \r\n    \t\"label\": \"Student ethnicity\", \r\n    \t\"hide_header\": true, \r\n    \t\"key\": \"ethnicity\" \r\n  \t}, \r\n  \t{ \r\n    \t\"label\": \"School value\", \r\n    \t\"key\": \"school_value\", \r\n    \t\"format\": \"percentage\" \r\n  \t}, \r\n  \t{ \r\n    \t\"label\": \"State value\", \r\n    \t\"key\": \"state_value\", \r\n    \t\"format\": \"percentage\" \r\n  \t} \r\n  ] \r\n}"
)
CategoryPlacement.create!(category: dummy_category, layout: 'contact_overview', title: 'Contact Information', page: overview, position: 9, size: 12 )

# different config for different page - Quality
CategoryPlacement.create!(category: test_scores, page: quality, position: 6, size: 12, layout: 'test_scores')



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


CategoryData.create!(category: snapshot, response_key:'enrollment',sort_order: 1)
CategoryData.create!(category: snapshot, response_key:'hours',sort_order: 2)
CategoryData.create!(category: snapshot, response_key:'head official name',sort_order: 3)
CategoryData.create!(category: snapshot, response_key:'transportation',sort_order: 4)
CategoryData.create!(category: snapshot, response_key:'district',sort_order: 5)
CategoryData.create!(category: snapshot, response_key:'type',sort_order: 6)
CategoryData.create!(category: snapshot, response_key:'students per teacher',sort_order: 7)
CategoryData.create!(category: snapshot, response_key:'capacity',sort_order: 8)
CategoryData.create!(category: snapshot, response_key:'before_care',sort_order: 9)
CategoryData.create!(category: snapshot, response_key:'after_care',sort_order: 10)

CategoryData.create!(category: details_summary, response_key:'arts_media')
CategoryData.create!(category: details_summary, response_key:'arts_music')
CategoryData.create!(category: details_summary, response_key:'arts_performing_written')
CategoryData.create!(category: details_summary, response_key:'arts_visual')
CategoryData.create!(category: details_summary, response_key:'girls_sports')
CategoryData.create!(category: details_summary, response_key:'boys_sports')
CategoryData.create!(category: details_summary, response_key:'student_clubs')
CategoryData.create!(category: details_summary, response_key:'foreign_language')



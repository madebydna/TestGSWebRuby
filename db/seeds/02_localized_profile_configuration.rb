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
student_ethnicity = Category.create!(name: 'Student ethnicity', source: 'census_data')
english_language_learners = Category.create!(name: 'English language learners', source: 'census_data')
category_no_osp_data = Category.create!(name: 'Bogus Category w/o OSP Data', source:'esp_response')
test_scores = Category.create!(name: 'Test scores', source: 'test_scores')
snapshot = Category.create!(name: 'Snapshot', source: 'snapshot')
details_summary = Category.create!(name: 'Details', source:'details')
dummy_category = Category.create!(name: 'Dummy', source:'dummy')
student_subgroups = Category.create!(name: 'Student subgroups', source:'census_data')
ratings = Category.create!(name: 'Ratings', source:'rating_data')


# Category placements
# defaults (no collection)
# different config for different page  - Details
CategoryPlacement.create!(category: school_basics, page: details)
CategoryPlacement.create!(category: arts_music, page: details)
CategoryPlacement.create!(category: programs, page: details)
ethnicity_group = CategoryPlacement.create!(category: dummy_category, page: details, title: 'Student ethnicity', layout: 'group', layout_config: (
  {
      child_sizes: [
          { xs: 4, sm: 4, md: 4, lg: 4 },
          { xs: 8, sm: 8, md: 8, lg: 8 }
      ]
  }).to_json
)
ethnicity_pie = CategoryPlacement.create!(
    category: student_ethnicity, page: details, title: 'Ethnicity pie chart', layout: 'pie_chart', layout_config: (
    {
      chart_name: 'ethnicity',
      columns: [
          { key: 'breakdown' },
          { key: 'school_value' }
      ]
    }).to_json
)
ethnicity_pie.parent = ethnicity_group
ethnicity_pie.save!

ethnicity_data = CategoryPlacement.create!(
    category: student_ethnicity, page: details, title: 'Ethnicity data', layout: 'configured_table',
    layout_config: ({
        hide_header: true,
        columns: [
            {
                label: 'Student ethnicity',
                hide_header: true,
                key: 'breakdown'
            },
            {
                label: 'This school',
                key: 'school_value',
                format: 'percentage',
                precision: 0
            },
            {
                label: 'State average',
                key: 'state_value',
                format: 'percentage',
                precision: 0
            }
        ]
    }).to_json
)
ethnicity_data.parent = ethnicity_group
ethnicity_data.save!

CategoryPlacement.create!(
    category: english_language_learners, page: details, title: 'English language learners', layout: 'configured_table',
    layout_config: ({
        columns: [
            {
                label: 'Language',
                hide_header: true,
                key: 'breakdown'
            },
            {
                label: 'This school',
                key: 'school_value',
                format: 'percentage',
                precision: 0
            },
            {
                label: 'State average',
                key: 'state_value',
                format: 'percentage',
                precision: 0
            }
        ]
    }).to_json
)


# different config for different page  - Overview
CategoryPlacement.create!(category: snapshot, page: overview, layout: 'snapshot', layout_config: "{ \"enrollment\": {\"format\": \"integer\"}}" )
CategoryPlacement.create!(category: dummy_category, layout: 'reviews_overview', title: 'Reviews Overview', page: overview)
CategoryPlacement.create!(category: dummy_category, layout: 'lightbox_overview', title: 'Media Gallery', page: overview)
CategoryPlacement.create!(category: details_summary, page: overview, title: 'Details', layout: 'details')
CategoryPlacement.create!(
    category: student_ethnicity, page: overview, title: 'Ethnicity pie chart', layout: 'pie_chart_overview', layout_config: (
    {
        chart_name: 'overview',
        columns: [
            { key: 'breakdown' },
            { key: 'school_value' }
        ]
    }).to_json
)
CategoryPlacement.create!(category: dummy_category, layout: 'contact_overview', title: 'Contact Information', page: overview)


# different config for different page - Quality
CategoryPlacement.create!(category: test_scores, page: quality, layout: 'test_scores')


ratings_section = CategoryPlacement.create!(category: dummy_category, page: quality, title: 'Rating', layout: 'section')
gs_rating = CategoryPlacement.create!(category: ratings, page: quality, title: 'GS Rating', layout: 'gs_ratings')
gs_rating.parent = ratings_section
gs_rating.save!
city_rating = CategoryPlacement.create!(category: ratings, page: quality, title: 'City Rating', layout: 'city_ratings')
city_rating.parent = ratings_section
city_rating.save!
state_rating = CategoryPlacement.create!(category: ratings, page: quality, title: 'State Rating', layout: 'state_ratings')
state_rating.parent = ratings_section
state_rating.save!

CategoryPlacement.create!(category: student_subgroups, page: details, layout: 'configured_table', layout_config: ({
    hide_header: false,
    columns: [
      { label: 'Label', key: 'key', hide_header: true },
      { label: 'This school', key: 'school_value', format: 'percentage', precision: 0 },
      { label: 'State average', key: 'state_value', format: 'percentage', precision: 0 }
    ]
  }).to_json
)



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
CategoryData.create!(category: snapshot, response_key:'school_type_affiliation',sort_order: 6)
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

CategoryData.create!(category: student_ethnicity, response_key:'Ethnicity')
CategoryData.create!(category: english_language_learners, response_key:'Home language')

CategoryData.create!(category: student_subgroups, response_key:'English learners')
CategoryData.create!(category: student_subgroups, response_key:'Students participating in free or reduced-price lunch program')

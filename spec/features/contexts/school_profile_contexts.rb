require 'spec_helper'
require 'factories/school_profile_page_factory'

shared_context 'Given basic school profile page' do |page_name = nil|
  let!(:profile_page) { SchoolProfilePageFactory.new(page_name).page }
end

shared_context 'Given school profile page with Snapshot module' do |page_name| nil
  let!(:profile_page) do
    SchoolProfilePageFactory.new(page_name).
        with_snapshot_module
  end
end

shared_context 'Given school profile page with GS Rating Snapshot module' do |page_name| nil
  let!(:profile_page) do
    SchoolProfilePageFactory.new(page_name).
        with_gs_rating_snapshot_module
  end
end

shared_context 'Given school profile page with zillow module' do |page_name| nil
  let!(:profile_page) do
    SchoolProfilePageFactory.new(page_name).
        with_zillow_module
  end
end


shared_context 'Given school profile page with quick links' do |page_name| nil
  let!(:profile_page) do
    SchoolProfilePageFactory.new(page_name).
        with_quick_links
  end
end

shared_context 'Given school profile page with Reviews Snapshot module' do |page_name| nil
  let!(:profile_page) do
    SchoolProfilePageFactory.new(page_name).
      with_reviews_snapshot_module
  end
end

shared_context 'Given school profile page with reviews section on overview' do |page_name = nil|
  let!(:profile_page) do
    SchoolProfilePageFactory.new(page_name).
      with_reviews_section_on_overview
  end
end

shared_context 'Visit School Profile Overview' do |s = nil|
  subject(:page_object) do
    visit school_path(s || school)
    SchoolProfileOverviewPage.new
  end
end

shared_context 'Visit School Profile Quality' do |s = nil|
  subject(:page_object) do
    visit school_quality_path(s || school)
    SchoolProfileQualityPage.new
  end
end

shared_context 'Given school profile page with media gallery on overview' do |page_name = nil|
  let!(:profile_page) do
    SchoolProfilePageFactory.new(page_name).
      with_media_gallery
  end
end

shared_context 'Given school profile page with Ratings on overview' do |page_name = nil|
  let!(:profile_page) do
    SchoolProfilePageFactory.new(page_name).
        with_gs_rating_snapshot_module
  end
end



shared_context 'Visit School Profile Details' do |s = nil|
  subject(:page_object) do
    visit school_details_path(s || school)
    SchoolProfileDetailsPage.new
  end
end

shared_context 'Given school profile page with school test guide module' do |page_name| nil
  let!(:profile_page) do
    SchoolProfilePageFactory.new(page_name).
      with_state_test_guide_module
  end
end

shared_context 'with Cesar Chavez Academy Denver' do
  let!(:school) { FactoryGirl.create(:cesar_chavez_academy_denver) }
  after do
    clean_models :co, School
  end
end
shared_context 'with Alameda High School' do
  let!(:school) { FactoryGirl.create(:alameda_high_school) }
  after do
    clean_models :ca, School
  end
end

shared_context 'with a Washington, DC school' do
  let!(:school) do
    s = FactoryGirl.build(:washington_dc_ps_head_start)
    s.on_db(:dc).save
    s
  end
  after do
    clean_models :dc, School
  end
end

shared_context 'with elementary school in CA' do
  let!(:school) { FactoryGirl.create(:bay_farm_elementary_school) }
  after do
    clean_models :ca, School
  end
end

shared_context 'with Cristo Rey New York High School' do
  let!(:school) do 
    new_york_school = FactoryGirl.build(:cristo_rey_new_york_high_school) 
    School.on_db(:ny) { new_york_school.save}
    new_york_school
  end
  after do
    clean_models :ny, School
  end
end

shared_context 'with Cesar Chavez Academy Denver' do
  let!(:school) do
    colorado_school = FactoryGirl.build(:cesar_chavez_academy_denver) 
    School.on_db(:co) { colorado_school.save}
    colorado_school 
  end
  after do
    clean_models :co, School
  end
end
shared_context 'Given school profile page with Contact this school section' do |page_name|
  nil
  let!(:profile_page) do
    SchoolProfilePageFactory.new(page_name).
        with_contact_this_school_section
  end
end

shared_context 'with apply now URL in school metadata' do
  let!(:apply_now_url_metadata) do
    SchoolMetadata.create(
      school_id: school.id,
      meta_key: 'apply_now_url',
      meta_value: 'http://www.schoolchoicede.org/ApplyInfo/AppoKN'
    )
  end
end

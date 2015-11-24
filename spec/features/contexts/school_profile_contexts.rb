require 'spec_helper'
require_relative '../localized_profiles/school_profile_page_factory'

shared_context 'Given basic school profile page' do |page_name = nil|
  let!(:profile_page) { SchoolProfilePageFactory.new(page_name).page }
end

shared_context 'Given school profile page with Facebook module' do |page_name| nil
  let!(:profile_page) do
    SchoolProfilePageFactory.new(page_name).
      with_facebook_like_box_module
  end
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

shared_context 'Given school profile page with Reviews Snapshot module' do |page_name| nil
  let!(:profile_page) do
    SchoolProfilePageFactory.new(page_name).
      with_reviews_snapshot_module
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


shared_context 'Visit School Profile Details' do |s = nil|
  subject(:page_object) do
    visit school_details_path(s || school)
    SchoolProfileDetailsPage.new
  end
end

shared_context 'Visit School Profile Reviews' do |s = nil|
  let(:page_object) do
    visit school_reviews_path(s || school)
    SchoolProfileReviewsPage.new
  end
  before do
    visit school_reviews_path(s || school)
  end
  subject do
    page_object
  end
end

shared_context 'Given school profile page with school test guide module' do |page_name| nil
  let!(:profile_page) do
    SchoolProfilePageFactory.new(page_name).
      with_state_test_guide_module
  end
end

shared_context 'with Alameda High School' do
  let!(:school) { FactoryGirl.create(:alameda_high_school) }
  after do
    clean_models School
  end
end

shared_context 'with elementary school in CA' do
  let!(:school) { FactoryGirl.create(:bay_farm_elementary_school) }
  after do
    clean_models School
  end
end

shared_context 'with Cristo Rey New York High School' do
  let!(:school) do 
    new_york_school = FactoryGirl.build(:cristo_rey_new_york_high_school) 
    School.on_db(:ny) { new_york_school.save}
    new_york_school
  end
  after do
    clean_models School
    clean_dbs(:ny)
  end
end

shared_context 'with Cesar Chavez Academy Denver' do
  let!(:school) do
    colorado_school = FactoryGirl.build(:cesar_chavez_academy_denver) 
    School.on_db(:co) { colorado_school.save}
    colorado_school 
  end
  after do
    clean_models School
    clean_dbs(:co)
  end
end

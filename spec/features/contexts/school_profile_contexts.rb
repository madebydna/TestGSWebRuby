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

shared_context 'Visit School Profile Overview' do |s = nil|
  subject do
    visit school_path(s || school)
    SchoolProfileOverviewPage.new
  end
end

shared_context 'Visit School Profile Reviews' do |s = nil|
  subject do
    visit school_reviews_path(s || school)
    SchoolProfileReviewsPage.new
  end
end

shared_context 'with Alameda High School' do
  let!(:school) { FactoryGirl.create(:alameda_high_school) }
end
require 'spec_helper'

feature 'Write a Review Page' do
  let(:school) { FactoryGirl.create(:school) }
  after(:each) { clean_models :ca, School }
  subject do
    visit school_review_form_path(school)
    page
  end

  feature 'User loads the page' do
    scenario 'It shows review form with title' do
      expect(subject).to have_content("Write a review about #{school.name}")
    end
  end
end
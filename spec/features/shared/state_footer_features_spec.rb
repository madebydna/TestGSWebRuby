require 'spec_helper'

shared_examples_for 'page with state footer features' do
  before(:each) do
    @page = FactoryGirl.create(:page)
  end
  let(:school) { FactoryGirl.create(:alameda_high_school) }
  subject do
    visit school_path(school)
    page
  end
  after(:each) do
    clean_models School, Page, City
  end

  feature 'state specific footer' do
    before(:each) do
      FactoryGirl.create(:city, name:'A city in California', state: 'CA')
      FactoryGirl.create(:city, name:'A city in New York', state: 'NY')
    end
    scenario 'should contain cities for current state' do
      expect(subject).to have_content('Find the great schools in California')
      expect(subject).to have_content('A city in California')
      expect(subject).to_not have_content('A city in New york')
    end
  end
end
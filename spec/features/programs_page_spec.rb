require 'spec_helper'

describe 'Programs Page' do
  let(:url) { '/michigan/detroit/programs' }
  before do
    FactoryGirl.create :hub_city_mapping
    FactoryGirl.create :programs_heading_config
    FactoryGirl.create :programs_intro_config
    FactoryGirl.create :programs_sponsor_config
    FactoryGirl.create :important_events_collection_config
    visit '/michigan/detroit/programs'
  end
  after { clean_dbs :gs_schooldb }

  describe 'heading and intro section' do
    it 'renders the search bar' do
      expect(page).to have_selector '#js-findByNameBox'
    end

    it 'renders the upcoming events bar' do
      expect(page).to have_selector '.upcoming-event'
    end

    it 'displays a configurable heading' do
      expect(page).to have_selector 'h1', text: 'What makes a great after school or summer program?'
    end

    it 'renders the intro section' do
      expect(page).to have_content 'Quality after-school and summer learning opportunities.'
    end
  end

  describe 'sponsor section' do
    it 'renders the sponsor section' do
      expect(page).to have_content 'description of an excellent sponsor'
    end
  end
end

require 'spec_helper'

describe 'Programs Page' do
  before { FactoryGirl.create :hub_city_mapping }
  after { clean_dbs :gs_schooldb }
  let(:url) { '/michigan/detroit/programs' }

  context 'without data' do
    before { visit url }

    it 'renders an empty page' do
      expect(page.status_code).to eq(200)
    end
  end

  context 'by default' do
    before do
      FactoryGirl.create :programs_heading_config
      FactoryGirl.create :programs_intro_config
      FactoryGirl.create :programs_sponsor_config
      FactoryGirl.create :programs_partners_config
      FactoryGirl.create :programs_articles_config
      FactoryGirl.create :important_events_collection_config
      visit url
    end

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

    it 'renders the sponsor section' do
      expect(page).to have_content 'description of an excellent sponsor'
    end

    it 'renders the resources section' do
      expect(page).to have_selector 'h4', text: 'Facebook Aquires Greatschools'
    end

    it 'shows breadcrumbs' do
      expect(page).to have_css("span[itemtype='http://data-vocabulary.org/Breadcrumb']", count: 2)
    end

    it 'renders the articles module' do
      expect(page).to have_content 'Resources in San Francisco'
    end
  end
end

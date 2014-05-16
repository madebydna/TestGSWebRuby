require 'spec_helper'

describe 'Events Page' do
  let(:events_page_url) { 'http://localhost:3000/michigan/detroit/events' }
  before(:each) do
    Timecop.travel(Date.new(2013, 1, 2))
    FactoryGirl.create(:hub_city_mapping)
    FactoryGirl.create(:important_events_collection_config)
    CollectionConfig.where(quay: CollectionConfig::NICKNAME_KEY, collection_id: 1, value: 'Detroit').create
    visit events_page_url
  end
  after(:each) { clean_dbs :gs_schooldb }

  after(:each) do
    Timecop.return
  end

  it 'shows basic layout and breadcrumbs' do
    expect(page).to have_text 'All events'
    expect(page).to have_css("span[itemtype='http://data-vocabulary.org/Breadcrumb']", count: 3)
  end

  describe 'search bar' do
    it 'exists' do
      expect(page).to have_content 'Find a school in Detroit'
      expect(page).to have_content 'Not in Detroit?'
      expect(page).to have_css('.search-bar')
    end
  end

  it 'shows all upcoming events' do
    expect(page).to have_css('.iconx48', count: 3)
    expect(page).to have_link('Find out more', count: 3)
  end
end

require 'spec_helper'

events_value_str = "{ events: [   {     date: '02-17-2014',     description: 'DPS: Mid-Winter Break Starts',    url: 'http://detroitk12.org/calendars/academic/'  },  {     date: '03-19-2014',     description:'DPS: Schools Closed',    url: 'http://detroitk12.org/calendars/academic/'  },  {     date: '04-12-2014',     description: 'Loyola High School Open House',     url: 'http://www.aod.org/schools/choose-catholic-high-schools/high-school-open-houses-and-testing/'   } ] } "

describe 'Events Page' do
  let(:events_page_url) { 'http://localhost:3000/michigan/detroit/events' }
  before(:each) do
    if CollectionMapping.where(city: 'detroit', state: 'mi', active: 1).empty?
      cm = CollectionMapping.new(city: 'detroit', state: 'mi')
      cm.collection_id = 1
      cm.active = 1
      cm.save!
    end

    if CollectionConfig.where(collection_id: 1, quay: CollectionConfig::CITY_HUB_IMPORTANT_EVENTS_KEY).empty?
      cc = CollectionConfig.new
      cc.collection_id = 1
      cc.quay = CollectionConfig::CITY_HUB_IMPORTANT_EVENTS_KEY
      cc.value = events_value_str
      cc.save
    end
  end

  after(:each) do
    CollectionMapping.destroy_all
    CollectionConfig.destroy_all
  end

  it 'shows basic layout and breadcrumbs' do
    visit events_page_url
    expect(page).to have_text 'All events'
    expect(page).to have_css("span[itemtype='http://data-vocabulary.org/Breadcrumb']", count: 3)
  end

  describe 'search bar' do
    it 'exists' do
      visit events_page_url
      expect(page).to have_content 'Find a school in Detroit'
      expect(page).to have_content 'Not in Detroit?'
      expect(page).to have_css('.search-bar')
    end
  end

  it 'shows all upcoming events' do
    visit events_page_url
    expect(page).to have_css('.iconx48', count: 2)
    expect(page).to have_link('Find out more', count: 2)
  end
end

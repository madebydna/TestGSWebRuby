require 'spec_helper'

describe 'Events Page' do
  let(:events_page_url) { 'http://localhost:3000/michigan/detroit/events' }
  before(:each) { CollectionMapping.destroy_all; CollectionConfig.destroy_all }
  before(:each) do
    FactoryGirl.create(:collection_mapping)
    FactoryGirl.create(:important_events_collection_config)
    visit events_page_url
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
    expect(page).to have_css('.iconx48', count: 2)
    expect(page).to have_link('Find out more', count: 2)
  end
end

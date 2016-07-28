require 'spec_helper'
require 'features/page_objects/city_home_page'
require 'features/examples/page_examples'
require 'features/contexts/state_home_contexts'
require 'features/examples/footer_examples'

describe 'Events Page' do
  let(:events_page_url) { 'http://localhost:3000/michigan/detroit/events' }
  before(:each) do
    Timecop.travel(Date.new(2013, 1, 2))
    FactoryGirl.create(:hub_city_mapping)
    FactoryGirl.create(:important_events_collection_config)
    CollectionConfig.where(quay: CollectionConfig::NICKNAME_KEY, collection_id: 1, value: 'Detroit').create
    visit events_page_url
  end
  subject { CityHomePage.new }
  after(:each) { clean_dbs :gs_schooldb }

  after(:each) do
    Timecop.return
  end

  include_examples 'should have a footer'

  it 'shows basic layout and breadcrumbs' do
    expect(page).to have_text 'All events'
    expect(page).to have_css("span[itemtype='http://data-vocabulary.org/Breadcrumb']")
  end

  describe 'search bar' do
    it 'exists' do
      expect(page).to have_content 'Find a school in Detroit'
      expect(page).to have_content 'Not in Detroit?'
      expect(page).to have_css '#js-findByNameBox'
    end
  end

  it 'shows all upcoming events' do
    expect(page).to have_css '.iconx48-cal', count: 3
    expect(page).to have_link 'Find out more', count: 3
  end

  describe 'breadcrumbs' do
    subject { CityHomePage.new }

    it { is_expected.to have_breadcrumbs }
    its('first_breadcrumb.title') { is_expected.to have_text('Michigan') }
    its('first_breadcrumb') { is_expected.to have_link('Michigan', href: "/michigan/") }
    its('second_breadcrumb.title') { is_expected.to have_text('Detroit') }
    its('second_breadcrumb') { is_expected.to have_link('Detroit', href: "/michigan/detroit/") }
  end
end

require 'spec_helper'
require 'sample_data_helper'

feature 'configurable dropdown menu', caching: true do
  let(:dropdown_item_selector) { 'li:first-child .dropdown-menu li a' }
  let(:clear_cookies_selector) { '.dropdown-menu .js-clear-local-cookies-link' }
  let(:dbs) { [:gs_schooldb, :mi, :de, :ca] }

  before(:each) do
    clean_dbs *dbs
    [
      { collection_id: 1, city: 'detroit', state: 'MI', active: 1, hasEduPage: 1, hasChoosePage: 1, hasEventsPage: 1, hasEnrollPage: 1, hasPartnerPage: 1 },
      { collection_id: 2, city: 'Oakland', state: 'CA', active: 1, hasEduPage: 0, hasChoosePage: 0, hasEventsPage: 0, hasEnrollPage: 0, hasPartnerPage: 0 },
      { collection_id: 6, city: nil, state: 'IN', active: 1, hasStateEduPage: 1, hasStateChoosePage: 1, hasStateEnrollPage: 0, hasStatePartnerPage: 1 },
      { collection_id: 7, city: nil, state: 'OH', active: 1, hasEduPage: 0, hasChoosePage: 0 },
      { collection_id: 8, city: nil, state: 'NC', active: 1, hasEduPage: 1, hasChoosePage: 0 },
      { collection_id: 9, city: nil, state: 'DE', active: 1, hasEduPage: 1, hasChoosePage: 0 }
    ].each { |attributes| HubCityMapping.new(attributes, without_protection: true).save }

    fixtures = [
      { file: 'bates_academy_profile', state: :mi, collection_id: 1 },
      { file: 'campus_community_profile', state: :de, collection_id: 9 },
      { file: 'washington_high_profile', state: :ca, collection_id: nil }
    ]

    fixtures.each do |fixture|
      load_sample_data fixture[:file], Rails.env
      school = School.on_db(fixture[:state]).first
      SchoolMetadata.on_db(fixture[:state]).create(school_id: school.id, meta_key: 'collection_id', meta_value: fixture[:collection_id].to_s) if fixture[:collection_id]
    end

    FactoryGirl.create(:page)
  end
  after(:each) { clean_dbs *dbs }

  scenario 'on a city page with all pages' do
    visit '/michigan/detroit'

    # Should have all the city page links
    expect(page).to have_selector('li:first-child .dropdown-menu li a', count: 6)
    links = ['Detroit Home', 'Choosing a School', 'Education Community', 'Enrollment Information', 'Events']
    links.each { |link| expect(page).to have_link(link) }
  end

  scenario 'on a city page with no pages' do
    visit '/california/oakland'

    # The page only has the default 2 links
    expect(page).to have_selector(dropdown_item_selector, count: 2)
    expect(page).to have_selector(clear_cookies_selector)
  end

  scenario 'on a state page' do
    visit '/indiana'

    expect(page).to have_selector(dropdown_item_selector, count: 5)
    links = ['Indiana Home', 'Choosing a School', 'Education Community']
    links.each { |link| expect(page).to have_link(link) }
    expect(page).to have_selector(clear_cookies_selector)
  end

  scenario 'from a state page to the login page' do
    visit '/indiana'

    expect(page).to have_selector('.dropdown-toggle', text: 'Indiana')
    expect(page).to have_selector(dropdown_item_selector, text: 'Indiana Home')

    visit '/gsr/login'
    expect(page).to have_selector('.dropdown-toggle', text: 'Indiana')
    expect(page).to have_selector(dropdown_item_selector, text: 'Indiana Home')
  end

  scenario 'from a state page with baby pages to one without baby pages' do
    indiana_links = ['Indiana Home', 'Choosing a School', 'Education Community']
    ohio_links = ['Choosing a School', 'Education Community']

    visit '/indiana'
    expect(page).to have_selector('.dropdown-toggle', text: 'Indiana')
    indiana_links.each { |link| expect(page).to have_link(link) }

    visit '/ohio'
    expect(page).to have_selector('.dropdown-toggle', text: 'Ohio')
    expect(page).to have_link('Ohio Home')
    ohio_links.each { |link| expect(page).to_not have_link(link) }
  end

  scenario 'hub profile to hub profile' do
    visit '/indiana'
    visit '/michigan/detroit/1-bates-academy'
    visit '/michigan/detroit'
    visit '/delaware/dover/100-campus-community-school'

    expect(page).to have_selector('.dropdown-toggle', text: 'Delaware')
    expect(page).to_not have_selector('.dropdown-toggle', text: 'Detroit, MI')
  end

  scenario 'hub profile to school without a collection' do
    visit '/michigan/detroit'
    visit '/california/fremont/1-Washington-High-School/'

    expect(page).to have_selector('.dropdown-toggle', text: 'Detroit, MI')
  end
end

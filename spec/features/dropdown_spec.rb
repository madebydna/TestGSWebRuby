require 'spec_helper'

feature 'configurable dropdown menu' do
  let(:dropdown_item_selector) { 'li:first-child .dropdown-menu li a' }
  let(:clear_cookies_selector) { '.dropdown-menu .js-clear-local-cookies-link' }

  before(:each) do
    clean_dbs :gs_schooldb
    [
      { collection_id: 1, city: 'detroit', state: 'MI', active: 1, hasEduPage: 1, hasChoosePage: 1, hasEventsPage: 1, hasEnrollPage: 1, hasPartnerPage: 1 },
      { collection_id: 2, city: 'Oakland', state: 'CA', active: 1, hasEduPage: 0, hasChoosePage: 0, hasEventsPage: 0, hasEnrollPage: 0, hasPartnerPage: 0 },
      { collection_id: 6, city: nil, state: 'IN', active: 1, hasStateEduPage: 1, hasStateChoosePage: 1, hasStateEnrollPage: 0, hasStatePartnerPage: 1 },
      { collection_id: 7, city: nil, state: 'OH', active: 1, hasEduPage: 1, hasChoosePage: 0 },
      { collection_id: 8, city: nil, state: 'NC', active: 1, hasEduPage: 1, hasChoosePage: 0 },
      { collection_id: 9, city: nil, state: 'DE', active: 1, hasEduPage: 1, hasChoosePage: 0 }
    ].each { |attributes| HubCityMapping.new(attributes, without_protection: true).save }
  end
  after(:each) { clean_dbs :gs_schooldb }

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

    click_link 'Sign In'
    expect(page).to have_selector('.dropdown-toggle', text: 'Indiana')
    expect(page).to have_selector(dropdown_item_selector, text: 'Indiana Home')
  end
end

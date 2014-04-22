require 'spec_helper'

describe 'City Hub Page' do
  let(:city_page_url) { '/michigan/detroit' }
  before(:all) do
    FactoryGirl.create(:hub_city_mapping)
    FactoryGirl.create(:important_events_collection_config)
    FactoryGirl.create(:city_hub_sponsor_collection_config)
    FactoryGirl.create(:feature_articles_collection_config)
    FactoryGirl.create(:city_hub_partners_collection_config)
    FactoryGirl.create(:announcement_collection_config)
    FactoryGirl.create(:show_announcement_collection_config)
    FactoryGirl.create(:choose_a_school_collection_configs)
    FactoryGirl.create(:collection_nickname)
  end
  after(:all) { clean_dbs :gs_schooldb }

  before(:each) { visit city_page_url }

  describe 'search' do
    it 'displays sponsor information' do
      expect(page).to have_css("a[href='education-community/partner']")
      expect(page).to have_xpath("//img[@alt='sponsor logo']")
    end
  end

  describe 'school breakdown section' do
    it 'shows the counts for each school type' do
      browse_link_selector = ".school-breakdown button span:last-child"

      expect(page).to have_css('.school-breakdown button', count: 7)
      page.all(browse_link_selector).each do |link|
        expect(link.text).to match(/[0-9]/)
      end
    end
  end

  describe 'choose a school section' do
    it 'renders links for a city hub' do
      expect(page).to have_content 'Finding a Great School in Detroit'
      expect(page).to have_css('#choose-a-school a', count: 3)
    end
  end

  describe 'upcoming events section' do
    it 'shows 2 upcoming events' do
      expect(page).to have_css('.upcoming-event', count: 2)
    end
    it 'shows announcements' do
      expect(page).to have_css('.success-block')
      expect(page).to have_css('span', text: 'ANNOUNCEMENT', count: 1)
      expect(page).to have_link 'Learn More'
    end
  end

  describe 'join our community' do
    it 'renders the join well', js: true do
      expect(page).to have_content('Join our community')
      click_button 'Join'
      expect(current_path).to eq('/gsr/login/')
    end
  end

  describe 'featured articles section' do
    it 'display featured articles' do
      expect(page).to have_css('.js-featured-article', count: 3)
    end
    it 'shows nearby homes with zillow' do
      expect(page).to have_content 'Nearby Homes for Sale'
      expect(page).to have_css('iframe')
    end
  end

  describe 'education community carousel' do
    it 'shows the carousel', js: true do
      cycle_function = page.evaluate_script("$('.cycle-slideshow').cycle")
      expect(cycle_function).to_not be_nil
      expect(page).to have_css('.cycle-slide')
    end
  end
end

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
end

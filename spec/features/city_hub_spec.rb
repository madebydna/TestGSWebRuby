require 'spec_helper'

describe 'City Hub Page', js: true do
  let(:city_page_url) { 'http://localhost:3000/michigan/detroit' }
  before(:each) do
    CollectionConfig.where(quay: CollectionConfig::NICKNAME_KEY, collection_id: 1, value: 'Detroit').first_or_create
    visit city_page_url
  end

  describe 'search' do
    it 'searches and redirects to java results' do
      pending
    end

    it 'displays sponsor information' do
      expect(page).to have_css("a[href='education-community/partner']")
      expect(page).to have_xpath("//img[@alt='sponsor logo']")
    end
  end

  describe 'school breakdown section' do
    it 'shows the counts for each school type' do
      button1 = ".school-breakdown button:nth-of-type(#{rand(7) + 1}) span"
      button2 = ".school-breakdown button:nth-of-type(#{rand(7) + 1}) span"

      expect(page).to have_css('.school-breakdown button', count: 7)
      expect(find(button1).text).to match(/[0-9]/)
      expect(find(button2).text).to match(/[0-9]/)
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

  describe 'recent reviews section' do
    it 'show two most recent reviews for a city hub' do
      expect(page).to have_css('button.js-button-link', text: 'Review Your School')
      expect(page).to have_css('.recent-review', count: 2)
    end
  end

  describe 'join our community' do
    it 'renders the join well' do
      expect(page).to have_content('Join our community')
      click_button 'Join'
      expect(current_path).to eq('/gsr/login/')
    end
  end

  describe 'featured articles section' do
    it 'display featured articles' do
      expect(page).to have_css('.featured-article', count: 3)
    end
    it 'shows nearby homes with zillow' do
      expect(page).to have_content 'Nearby Homes for Sale'
      expect(page).to have_css('iframe')
    end
  end

  describe 'education community carousel' do
    it 'shows the carousel' do
      cycle_function = page.evaluate_script("$('.cycle-slideshow').cycle")
      expect(cycle_function).to_not be_nil
      expect(page).to have_css('.cycle-slide')
    end
  end
end

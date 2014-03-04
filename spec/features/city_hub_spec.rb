require 'spec_helper'

describe 'City Hub Page', js: true do
  let(:city_page_url) { 'http://localhost:3000/michigan/detroit' }

  describe 'entering a falty url' do
    it 'renders the error page' do
      visit 'http://localhost:3000/michigan/foobar'
      expect(page).to have_content 'Page Not Found'
    end
  end

  describe 'noSchoolAlert param' do
    it 'shows an error partial' do
      error_message = "Oops! The school you were looking for may no longer exist."
      visit city_page_url + '/?noSchoolAlert=1'
      expect(page).to have_content error_message
      visit city_page_url
      expect(page).to_not have_content error_message
    end
  end

  describe 'search' do
    it 'searches and redirects to java results' do
      pending("haven't implemented ruby side of results yet")
    end
  end

  describe 'school breakdown section' do
    it 'shows the counts for each school type' do
      visit city_page_url

      expect(all('.school-breakdown button').length).to eq(7)
      expect(find('.school-breakdown button:nth-of-type(1) div:nth-of-type(2)').text).to eq('196')
      expect(find('.school-breakdown button:nth-of-type(7) div:nth-of-type(2)').text).to eq('118')
    end
  end

  describe 'choose a school section' do
    it 'renders links for a city hub' do
      visit city_page_url
      expect(page).to have_content 'Finding a Great School in Detroit'
      expect(all('#choose-a-school a').length).to eq(3)
    end
  end

  describe 'upcoming events section' do
    it 'shows 2 upcoming events' do
      visit city_page_url
      expect(all('.upcoming-event').length).to eq(2)
    end
    it 'shows announcements' do
      visit city_page_url
      expect(page).to have_css('.success-block')
      expect(all('span', text: 'ANNOUNCEMENT').length).to eq(1)
      expect(page).to have_link 'Learn More'
    end
  end

  describe 'recent reviews section' do
    it 'show two most recent reviews for a city hub' do
      visit city_page_url
      expect(page).to have_css('button.js-button-link', text: 'Review Your School')
      expect(all('.recent-review').length).to eq(2)
    end
  end

  describe 'join our community' do
    it 'renders the join well' do
      visit city_page_url
      expect(page).to have_content('Join our community')
      click_button 'Join'
      expect(current_path).to eq('/gsr/login/')
    end
  end

  describe 'featured articles section' do
    it 'display featured articles' do
      visit city_page_url
      expect(all('.featured-article').length).to eq(3)
    end
    it 'shows nearby homes with zillow' do
      visit city_page_url
      expect(page).to have_content 'Nearby Homes for Sale'
      expect(page).to have_css('iframe')
    end
  end

  describe 'education community carousel' do
    it 'shows the carousel' do
      visit city_page_url
      cycle_function = page.evaluate_script("$('.cycle-slideshow').cycle")
      expect(cycle_function).to_not be_nil
      expect(all('.cycle-slide').length).to eq(33)
    end
  end
end

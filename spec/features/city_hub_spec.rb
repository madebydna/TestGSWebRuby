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
      pending("haven't gotten there yet")
    end
  end

  describe 'choose a school section' do
    it 'renders links for a city hub' do
      visit city_page_url
      expect(page).to have_content 'Finding a Great School in Detroit'
      expect(all('#choose-a-school a').length).to eq(3)
    end
  end

  describe 'recent reviews section' do
    it 'show two most recent reviews for a city hub' do
      visit city_page_url
      expect(page).to have_css('#js-hubsRecentReviews button')
      expect(all('.recent-review').length).to eq(2)
    end
  end

  describe 'featured articles section' do
    it 'display featured articles' do
      featured_article_css = '.featured-articles>div'
      visit city_page_url
      expect(all(featured_article_css).length).to eq(3)
    end
    it 'shows nearby homes with zillow' do
      visit city_page_url
      expect(page).to have_content 'Nearby Homes for Sale'
      expect(page).to have_css('iframe')
    end
  end
end

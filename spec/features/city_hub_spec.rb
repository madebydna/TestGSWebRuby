require 'spec_helper'

describe 'City Hub Page', js: true do
  let(:city_page_url) { 'http://localhost:3000/michigan/detroit' }

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
end

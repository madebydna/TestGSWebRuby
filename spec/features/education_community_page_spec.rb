require 'spec_helper'

describe 'Education Comunity Page' do
  before(:each) do
      visit '/michigan/detroit/education-community'
  end

  describe 'search bar' do
    it 'exists' do
      expect(page).to have_content 'Find a school in Detroit'
      expect(page).to have_content 'Not in Detroit?'
      expect(page).to have_css '.search-bar'
    end
  end

  describe 'upcoming events module' do
    it 'shows 2 upcoming events' do
      expect(page).to have_content 'Upcoming Events'
      expect(page).to have_css '.upcoming-event', count: 2
    end
  end

  describe 'heading' do
    it 'shows the heading and subheading' do
      expect(page).to have_content 'Detroit Education Community'
      expect(page).to have_content "Education doesn't happen in a vacuum"
    end
  end

  describe 'body' do
    it 'shows community partners' do
      expect(page).to have_css('.community-partner-row', count: 11)
    end

    it 'shows links to other education community pages' do
      expect(page).to have_link('Education', href: 'education')
      expect(page).to have_link('Funders', href: 'funders')
    end
  end
end

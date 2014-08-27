require 'spec_helper'

describe 'shared/_upcoming_events.html.erb' do
  context 'without upcoming events' do
    it 'does not render an error message' do
      allow(view).to receive(:important_events) { nil }
      render

      expect(rendered).to_not have_content('No Upcoming Important Dates')
    end
  end
end


describe 'cities/_event_announcements.html.erb' do
  context 'wihtout announcements' do
    it 'renders an error message' do
      allow(view).to receive(:announcement) { nil }
      render

      expect(rendered).to have_content('No Data Found - _event_announcements.html.erb')
    end
  end
end

describe 'cities/_join_our_community.html.erb' do
  context 'with a current user' do
    it 'does not render' do
      allow(view).to receive(:current_user) { 'foobar' }
      render

      expect(rendered).to_not have_content('Join our community')
    end
  end
end


describe 'cities/_featured_articles' do
  context 'without featured articles' do
    it 'renders an error message' do
      assign(:zillow_data, {})
      allow(view).to receive(:articles) { nil }
      render

      expect(rendered).to have_content('No Data Found - cities/_featured_articles.html.erb')
    end
  end

  context 'without zillow data' do
    it 'renders an error message' do
      assign(:zillow_data, {})
      allow(view).to receive(:articles) { nil }
      render

      expect(rendered).to have_content("Your browser doesn't support frames.")
    end
  end
end

describe 'cities/_partner_carousel.html.erb' do
  context 'without partner data' do
    it 'does not render the carousel' do
      allow(view).to receive(:partner_carousel) { nil }
      render

      expect(rendered).to_not have_selector('.cycle-slideshow')
    end
  end
end

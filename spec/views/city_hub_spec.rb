require 'spec_helper'

describe 'cities/_choose_a_school.html.erb' do
  context 'without a choose_a_school' do
    it 'renders an error message' do
      view.stub(:choose_school) { nil }
      render

      expect(rendered).to have_content('No Data Found - _choose_a_school.html.erb')
    end
  end
end

describe 'cities/_upcoming_events.html.erb' do
  context 'without upcoming events' do
    it 'renders an error message' do
      view.stub(:important_events) { nil }
      render

      expect(rendered).to have_content('No Upcoming Important Dates')
    end
  end
end


describe 'cities/_event_announcements.html.erb' do
  context 'wihtout announcements' do
    it 'renders an error message' do
      view.stub(:announcement) { nil }
      render

      expect(rendered).to have_content('No Data Found - _event_announcements.html.erb')
    end
  end
end

describe 'cities/_join_our_community.html.erb' do
  context 'with a current user' do
    it 'does not render' do
      view.stub(:current_user) { 'foobar' }
      render

      expect(rendered).to_not have_content('Join our community')
    end
  end
end


describe 'cities/_featured_articles' do
  context 'without featured articles' do
    it 'renders an error message' do
      assign(:zillow_data, {})
      view.stub(:articles) { nil }
      render

      expect(rendered).to have_content('No Data Found - cities/_featured_articles.html.erb')
    end
  end

  context 'without zillow data' do
    it 'renders an error message' do
      assign(:zillow_data, {})
      view.stub(:articles) { nil }
      render

      expect(rendered).to have_content("Your browser doesn't support frames.")
    end
  end
end

describe 'cities/_partner_carousel.html.erb' do
  context 'without partner data' do
    it 'does not render the carousel' do
      view.stub(:partner_carousel) { nil }
      render

      expect(rendered).to_not have_selector('.cycle-slideshow')
    end
  end
end

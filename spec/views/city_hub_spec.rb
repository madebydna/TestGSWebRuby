require 'spec_helper'

describe 'cities/_search_hero.html.erb' do
  let(:city_page_url) { 'http://localhost:3000/michigan/detroit' }

  context 'without a sponsor' do
    it 'does not render sponsor information' do
      view.stub(:city) { 'detoit' }
      view.stub(:collection_id) { 1 }
      view.stub(:state) { { short: 'mi', long: 'michigan' } }
      view.stub(:breakdown_results) { [] }
      view.stub(:sponsor) { nil }
      render

      expect(rendered).to_not have_selector 'a[href="education-community/partner"]'
    end
  end

  context 'without breakdown results' do
    it 'renders an error message' do
      view.stub(:city) { 'detoit' }
      view.stub(:collection_id) { 1 }
      view.stub(:state) { { short: 'mi', long: 'michigan' } }
      view.stub(:sponsor) { { text: 'foo bar baz', path: 'http://google.com' } }
      view.stub(:breakdown_results) { { foo: nil, bar: nil } }
      render

      expect(rendered).to have_content('No data found for school breakdown')
    end
  end
end

describe 'cities/_choose_a_school.html.erb' do
  context 'without a choose_a_school' do
    it 'renders an error message' do
      view.stub(:choose_school) { nil }
      render

      expect(rendered).to have_content('No Data Found - _choose_a_school.html.erb')
    end
  end
end

describe 'cities/_upcoming_event.html.erb' do
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



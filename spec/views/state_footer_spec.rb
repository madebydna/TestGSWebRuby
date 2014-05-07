require 'spec_helper'

describe 'shared/_state_footer.html.erb' do
  before(:each) { clean_dbs :us_geo }
  after(:each) { clean_dbs :us_geo }
  before(:each) do
    view.stub(:state) { { long: 'Indiana', short: 'IN' } }
    view.stub(:city_params).and_return({ state: 'indiana', city: 'indianapolis' })
  end

  shared_examples_for 'it has a city list' do |city_count|
    it 'renders the right list of cities' do
      view.stub(:cities) { cities }
      render
      expect(rendered).to render_template('_popular_cities_in_state')
      expect(rendered).to have_selector('.js-city-list li a', count: city_count)
    end
  end


  context 'with cities' do
    let!(:cities) do
      (1..31).to_a.map do |i|
        FactoryGirl.create(:city, name: "Test City#{i}", population: "#{i}000".to_i)
      end
    end

    it_behaves_like 'it has a city list', 30
  end

  context 'with only a few cities' do
    let!(:cities) do
      (1..20).to_a.map do |i|
        FactoryGirl.create(:city, name: "Test City#{i}", population: "#{i}000".to_i)
      end
    end

    it_behaves_like 'it has a city list', 20
  end

  context 'without cities' do
    it 'renders popular cities in the country' do
      view.stub(:cities) { nil }
      render
      expect(rendered).to render_template('_popular_cities_in_country')
    end
  end
end


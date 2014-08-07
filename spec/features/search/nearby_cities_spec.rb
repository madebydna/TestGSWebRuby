require 'spec_helper'
require_relative 'nearby_cities_spec_helper'

describe 'Nearby cities on city browse' do
  include NearbyCitiesSpecHelper

  let(:dover_city_browse) { '/delaware/dover/schools' }
  let(:state) { {long: 'delaware', short: 'de'} }
  let(:city) { City.new(name: 'dover', state: 'de') }
  let(:nearby_cities) { set_up_nearby_cities }

  context 'with some nearby cities' do
    before do
      allow(City).to receive(:find_by_state_and_name).and_return(city)
      allow_any_instance_of(SearchNearbyCities).to receive(:search).and_return(nearby_cities)
      visit dover_city_browse
    end
    it 'should show the nearby cities' do
      expect(page).to have_content 'Nearby Cities:'
    end
  end

  context 'with no nearby cities' do
    before do
      allow(City).to receive(:find_by_state_and_name).and_return(city)
      visit dover_city_browse
    end
    it 'should not show the nearby cities info' do
      expect(page).to_not have_content 'Nearby Cities:'
    end
  end

end
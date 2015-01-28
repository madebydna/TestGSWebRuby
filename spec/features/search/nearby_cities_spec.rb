require 'spec_helper'
require_relative 'search_spec_helper'

describe 'Nearby cities on city browse' do
  include SearchSpecHelper

  let(:cities) { %w(Anthony Christina Harrison Keith) }
  let(:nearby_cities) { set_up_nearby_cities(cities) }

  context 'with some nearby cities' do
    before do
      set_up_city_browse('de','dover') { allow_any_instance_of(SearchNearbyCities).to receive(:search).and_return(nearby_cities) }
    end
    it 'should show the nearby cities' do
      expect(page).to have_content 'Nearby Cities:'
      cities.each do |city|
        expect(page).to have_content city
      end
    end
  end

  context 'with no nearby cities' do
    before do
      set_up_city_browse('de','dover')
    end
    it 'should not show the nearby cities info' do
      expect(page).to_not have_content 'Nearby Cities:'
    end
  end

end
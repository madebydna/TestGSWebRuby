require 'spec_helper'

describe City do
  after { clean_dbs :us_geo }

  describe '.popular_cities' do
    before(:each) do
      (1..10).to_a.map do |i|
        FactoryGirl.create(:city, name: "Test City#{i}", population: "#{i}000".to_i)
      end
    end

    it 'optionally limits results' do
      cities1 = City.popular_cities('IN', limit: 3).to_a
      cities2 = City.popular_cities('IN', limit: 5).to_a

      expect(cities1.size).to eq(3)
      expect(cities2.size).to eq(5)
    end
  end

  describe '.display_name' do
    let(:city) { City.first }

    context 'by default' do
      before { FactoryGirl.create(:city, name: 'Foobar') }

      it 'returns the city name' do
        expect(city.display_name).to eq(city.name)
      end
    end

    context 'with DC' do
      before { FactoryGirl.create(:city, state: 'DC') }

      it 'returns washington dc' do
        expect(city.display_name).to eq('Washington, DC')
      end
    end
  end

  describe '.find_neighbors' do
    let!(:san_francisco) { create(:city, name: "San Francisco", lat: 37.7628, lon: -122.435, state: 'CA')}
    let!(:oakland) { create(:city, name: "Oakland", lat: 37.7699, lon: -122.226, state: 'CA')}
    let!(:berkeley) { create(:city, name: "Berkeley", lat: 37.8667, lon: -122.299, state: 'CA')}
    let!(:inactive_city) { create(:city, name: "Inactive", active: false, lat: 37.8667, lon: -122.299, state: 'CA')}
    let!(:other_state) { create(:city, name: "Other State", lat: 37.8667, lon: -122.299, state: 'WA')}
    let!(:sacramento) { create(:city, name: "Sacramento", lat:38.5666, lon: -121.469, state: 'CA')}

    it 'should return cities within 60 miles in the same state' do
      expect(City.find_neighbors(san_francisco)).to include(oakland)
      expect(City.find_neighbors(san_francisco)).to include(berkeley)
    end

    it 'should only return active cities within 60 miles' do
      expect(City.find_neighbors(san_francisco)).not_to include(inactive_city)
    end

    it 'should not return cities further away' do
      expect(City.find_neighbors(san_francisco)).not_to include(sacramento)
    end

    it 'should not return cities in another state' do
      expect(City.find_neighbors(san_francisco)).not_to include(other_state)
    end
  end
end

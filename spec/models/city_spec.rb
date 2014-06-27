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
end

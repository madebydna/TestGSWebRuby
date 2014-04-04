require 'spec_helper'

describe City do
  describe '.popular_cities' do
    after(:each) { clean_dbs :us_geo }
    before(:each) do
      c1 = FactoryGirl.create(:city)
      FactoryGirl.create(:city, name: 'Test City', population: c1.population + 1000)
      FactoryGirl.create(:city, name: 'Test City2', population: c1.population + 2000)
    end

    it 'orders cities by population' do
      cities = City.popular_cities('IN').to_a
      expect(cities.first.population).to be > cities.last.population
    end
    it 'optionally limits results' do
      cities1 = City.popular_cities('IN', limit: 1).to_a
      cities2 = City.popular_cities('IN', limit: 2).to_a

      expect(cities1).to have(1).items
      expect(cities2).to have(2).item
    end
  end
end

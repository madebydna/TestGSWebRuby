require 'spec_helper'

describe City do
  describe '.popular_cities' do
    before(:each) do
      clean_dbs :us_geo
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
end

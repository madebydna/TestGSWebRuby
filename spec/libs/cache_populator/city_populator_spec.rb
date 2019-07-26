require "spec_helper"

describe CachePopulator::CityCachePopulator do
    
  context "validations" do
    it "validates that states can be 'all'" do
      populator = CachePopulator::CityCachePopulator.new(values: 'all', cache_keys: 'school_levels')
      expect(populator).to be_valid
    end

    it "validates that states, if given, should be a list of valid states" do
      populator = CachePopulator::CityCachePopulator.new(values: 'ca,foo,mi', cache_keys: 'school_levels')
      expect(populator).not_to be_valid 
      expect(populator.errors[:states]).to include("unless blank must have the value 'all' or be a list of valid states")
    end

    it "sets blank value for states to 'no state'" do
      populator = CachePopulator::CityCachePopulator.new(values: ':1,2,3', cache_keys: 'school_levels')
      expect(populator.states).to eq(['no state'])
      expect(populator).to be_valid 
    end
  end

  context "#cities_to_cache" do
    let(:city) { class_double("City").as_stubbed_const }

    it "returns all cities in all states if states value is 'all'" do
      populator = CachePopulator::CityCachePopulator.new(values: 'all', cache_keys: 'header')
      expect(city).to receive(:get_all_cities)
      populator.cities_to_cache('all')
    end

    it "returns select cities by ids if no state given" do
      populator = CachePopulator::CityCachePopulator.new(values: ':1,2,3', cache_keys: 'header')
      expect(city).to receive(:where).with({id: ['1', '2', '3']})
      populator.cities_to_cache('no state')
    end
    
    it "returns select cities by sql if city ids are not a comma-separated string" do
      populator = CachePopulator::CityCachePopulator.new(values: ':id not in (1,2,3)', cache_keys: 'header')
      expect(city).to receive(:where).with("id not in (1,2,3)")
      populator.cities_to_cache('no state')
    end

    it "returns city within state if state given" do
      populator = CachePopulator::CityCachePopulator.new(values: 'hi,ca', cache_keys: 'header')
      expect(city).to receive(:where).with(state: 'hi')
      populator.cities_to_cache('hi')
    end
  end

  context "#run" do
    after { clean_dbs :us_geo }
    let(:city_cacher) { class_double('CityCacher').as_stubbed_const }
    let!(:san_francisco) { create(:city, id: 1, name: "San Francisco", state: 'CA')}
    let!(:berkeley) { create(:city, id: 2, name: "Berkeley", state: 'CA')}
    let!(:new_york) { create(:city, id: 3, name: "New York", state: 'NY')}

    it "caches all cities if state is 'all'" do
      populator = CachePopulator::CityCachePopulator.new(values: 'all', cache_keys: 'header')
      expect(city_cacher).to receive(:create_cache).with(san_francisco, 'header')
      expect(city_cacher).to receive(:create_cache).with(berkeley, 'header')
      expect(city_cacher).to receive(:create_cache).with(new_york, 'header')
      populator.run
    end

    it "caches cities with given ids if no state specified" do
      populator = CachePopulator::CityCachePopulator.new(values: ':1,3', cache_keys: 'header')
      expect(city_cacher).to receive(:create_cache).with(san_francisco, 'header')
      expect(city_cacher).to receive(:create_cache).with(new_york, 'header')
      populator.run
    end

    it "caches cities in a given state" do
      populator = CachePopulator::CityCachePopulator.new(values: 'ca', cache_keys: 'header')
      expect(city_cacher).to receive(:create_cache).with(san_francisco, 'header')
      expect(city_cacher).to receive(:create_cache).with(berkeley, 'header')
      populator.run
    end
  end
    
end
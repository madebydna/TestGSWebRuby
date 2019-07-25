require "spec_helper"

describe CachePopulator::DistrictCachePopulator do

  context "#districts_to_cache" do
    let(:district) { class_double("District").as_stubbed_const }
    let(:dbl) { double }

    it "returns all districts in state if no ids specified" do
      populator = CachePopulator::DistrictCachePopulator.new(values: 'hi', cache_keys: 'district_schools_summary')
      expect(district).to receive(:on_db).with(:hi).and_return(dbl)
      expect(dbl).to receive(:all)
      populator.districts_to_cache('hi')
    end

    it "returns select districts in state if ids given" do
      populator = CachePopulator::DistrictCachePopulator.new(values: 'de:1,2,3', cache_keys: 'district_schools_summary')
      expect(district).to receive(:on_db).with(:de).and_return(dbl)
      expect(dbl).to receive(:where).with({id: ['1', '2', '3']})
      populator.districts_to_cache('de')
    end
    
    it "returns select districts by sql if district ids are not a comma-separated string" do
      populator = CachePopulator::DistrictCachePopulator.new(values: 'hi:id not in (1,2,3)', cache_keys: 'district_schools_summary')
      expect(district).to receive(:on_db).with(:hi).and_return(dbl)
      expect(dbl).to receive(:where).with("id not in (1,2,3)")
      populator.districts_to_cache('hi')
    end
  end

  context "#run" do
    after(:all) do
      do_clean_models(:ca, District)
      do_clean_models(:al, District)
    end
      
    let(:district_cacher) { class_double('DistrictCacher').as_stubbed_const }

    before(:all) do
      @alameda_city_unified = FactoryGirl.create_on_shard(:ca, :district, attributes_for(:alameda_city_unified))
      @oakland_unified = FactoryGirl.create_on_shard(:ca, :district, attributes_for(:oakland_unified))
      @sitka_school_district = FactoryGirl.create_on_shard(:al, :district, attributes_for(:sitka_school_district))
    end

    it "caches all districts if state is 'all'" do
      populator = CachePopulator::DistrictCachePopulator.new(values: 'all', cache_keys: 'district_schools_summary')
      expect(district_cacher).to receive(:create_cache).with(@sitka_school_district, 'district_schools_summary')
      expect(district_cacher).to receive(:create_cache).with(@alameda_city_unified, 'district_schools_summary')
      expect(district_cacher).to receive(:create_cache).with(@oakland_unified, 'district_schools_summary')
      populator.run
    end

    it "caches select districts in a given state if ids specified" do
      populator = CachePopulator::DistrictCachePopulator.new(values: "ca:#{@oakland_unified.id}", cache_keys: 'district_schools_summary')
      expect(district_cacher).to receive(:create_cache).with(@oakland_unified, 'district_schools_summary')
      populator.run
    end

    it "caches all districts in a given state" do
      populator = CachePopulator::DistrictCachePopulator.new(values: 'ca', cache_keys: 'district_schools_summary')
      expect(district_cacher).to receive(:create_cache).with(@alameda_city_unified, 'district_schools_summary')
      expect(district_cacher).to receive(:create_cache).with(@oakland_unified, 'district_schools_summary')
      expect(district_cacher).not_to receive(:create_cache).with(@sitka_school_district, 'district_schools_summary')
      populator.run
    end
  end
    
end
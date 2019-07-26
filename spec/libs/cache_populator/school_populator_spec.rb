require "spec_helper"

describe CachePopulator::SchoolCachePopulator do

  context "#schools_to_cache" do
    let(:school) { class_double("School").as_stubbed_const }
    let(:dbl) { double }

    it "returns all schools in state if no ids specified" do
      populator = CachePopulator::SchoolCachePopulator.new(values: 'hi', cache_keys: 'esp_responses')
      expect(school).to receive(:on_db).with(:hi).and_return(dbl)
      expect(dbl).to receive(:all)
      populator.schools_to_cache('hi')
    end

    it "returns select schools in state if ids given" do
      populator = CachePopulator::SchoolCachePopulator.new(values: 'de:1,2,3', cache_keys: 'esp_responses')
      expect(school).to receive(:on_db).with(:de).and_return(dbl)
      expect(dbl).to receive(:where).with({id: ['1', '2', '3']})
      populator.schools_to_cache('de')
    end
    
    it "returns select schools by sql if school ids are not a comma-separated string" do
      populator = CachePopulator::SchoolCachePopulator.new(values: 'hi:id not in (1,2,3)', cache_keys: 'esp_responses')
      expect(school).to receive(:on_db).with(:hi).and_return(dbl)
      expect(dbl).to receive(:where).with("id not in (1,2,3)")
      populator.schools_to_cache('hi')
    end
  end

  context "#run" do
    after(:all) do
      do_clean_models(:ca, School)
      do_clean_models(:co, School)
    end

    before(:all) do
      @alameda_high_school = FactoryGirl.create_on_shard(:ca, :school, attributes_for(:alameda_high_school))
      @bay_farm_elementary_school = FactoryGirl.create_on_shard(:ca, :school, attributes_for(:bay_farm_elementary_school))
      @cesar_chavez_academy_denver = FactoryGirl.create_on_shard(:co, :school, attributes_for(:cesar_chavez_academy_denver))
    end

    let(:school_cacher) { class_double('Cacher').as_stubbed_const }

    it "caches all schools if state is 'all'" do
      populator = CachePopulator::SchoolCachePopulator.new(values: 'all', cache_keys: 'esp_responses')
      expect(school_cacher).to receive(:create_cache).with(@alameda_high_school, 'esp_responses')
      expect(school_cacher).to receive(:create_cache).with(@bay_farm_elementary_school, 'esp_responses')
      expect(school_cacher).to receive(:create_cache).with(@cesar_chavez_academy_denver, 'esp_responses')
      populator.run
    end

    it "caches select schools in a given state if ids specified" do
      populator = CachePopulator::SchoolCachePopulator.new(values: "ca:#{@alameda_high_school.id}", cache_keys: 'esp_responses')
      expect(school_cacher).to receive(:create_cache).with(@alameda_high_school, 'esp_responses')
      populator.run
    end

    it "caches all schools in a given state" do
      populator = CachePopulator::SchoolCachePopulator.new(values: 'ca', cache_keys: 'esp_responses')
      expect(school_cacher).to receive(:create_cache).with(@alameda_high_school, 'esp_responses')
      expect(school_cacher).to receive(:create_cache).with(@bay_farm_elementary_school, 'esp_responses')
      expect(school_cacher).not_to receive(:create_cache).with(@cesar_chavez_academy_denver, 'esp_responses')
      populator.run
    end
  end
end
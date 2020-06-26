require "spec_helper"

describe CachePopulator::StateCachePopulator do

  context "validations" do
    it "validates correct states" do
      populator = CachePopulator::StateCachePopulator.new(values: 'ca,foo', cache_keys: 'metrics,ratings')
      expect(populator).not_to be_valid
      expect(populator.errors[:states]).to include("must have the value 'all' or be a list of valid states")
    end
  end

  context "#run" do
    subject { CachePopulator::StateCachePopulator.new(values: 'ca,hi', cache_keys: 'metrics,ratings') }

    it "calls StateCacher.create_cache for each state and key combination" do
        state_cacher = class_double("StateCacher").as_stubbed_const
        expect(state_cacher).to receive(:create_cache).with('ca', 'metrics')
        expect(state_cacher).to receive(:create_cache).with('ca', 'ratings')
        expect(state_cacher).to receive(:create_cache).with('hi', 'metrics')
        expect(state_cacher).to receive(:create_cache).with('hi', 'ratings')
        subject.run
    end
  end
end
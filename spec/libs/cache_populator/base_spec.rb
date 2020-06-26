require "spec_helper"

describe CachePopulator::Base do
  subject { CachePopulator::Base.new(values: 'ca,hi, ak', cache_keys: 'foo,bar') }

  module CachePopulator
    class FooPopulator < Base
      CACHE_KEYS = %w(foo bar baz)
    end
  end

  context "initialization" do
    it "requires a values and cache_keys named arguments" do
      expect { subject }.not_to raise_error
      expect { CachePopulator::Base.new }.to raise_error(ArgumentError, /missing keyword.+values/)
      expect { CachePopulator::Base.new }.to raise_error(ArgumentError, /missing keyword.+cache_keys/)
    end

    it "splits values into states and optional_ids by comma" do
      expect(subject.states).to eq(['ca', 'hi', 'ak'])
      expect(subject.optional_ids).to be_nil
    end

    it "splits cache_keys by comma" do
      expect(subject.cache_keys).to eq(['foo', 'bar'])
    end
  end

  context "validations" do
    it "validates presence of states" do
      populator = CachePopulator::Base.new(values: '', cache_keys: 'foo,bar')
      expect(populator.valid?).to be false
      expect(populator.errors[:states]).to include("can't be blank")
    end

    it "validates presence of cache_keys" do
      populator = CachePopulator::Base.new(values: 'ca', cache_keys: '')
      expect(populator.valid?).to be false
      expect(populator.errors[:cache_keys]).to include("can't be blank")
    end

    it "checks for valid cache_keys according to inheriting class" do
      populator = CachePopulator::FooPopulator.new(values: 'al,ak', cache_keys: 'quux')
      expect(populator.valid?).to be false
      expect(populator.errors[:cache_keys]).to include("must have the value 'all' or be a list of valid cache keys")
    end

    it "allows for 'all' value in cache_keys" do
      populator = CachePopulator::Base.new(values: 'al,ak', cache_keys: 'all')
      expect(populator.valid?).to be true
    end

    it "allows for 'all' value for states" do
      populator = CachePopulator::FooPopulator.new(values: 'all', cache_keys: 'foo,bar')
      expect(populator.states).to eq(['all'])
      expect(populator.valid?).to be true
    end

    it "validates correct states" do
      populator = CachePopulator::StateCachePopulator.new(values: 'ca,foo', cache_keys: 'metrics,ratings')
      expect(populator).not_to be_valid
      expect(populator.errors[:states]).to include("must have the value 'all' or be a list of valid states")
    end
  end

  context "#states_to_cache" do
    it "should return all States if value is all" do
      populator = CachePopulator::Base.new(values: 'all', cache_keys: 'foo')
      expect(populator.states_to_cache).to eq(States.abbreviations)
    end

    it "should return defined list of state strings" do
      populator = CachePopulator::Base.new(values: 'al,hi', cache_keys: 'foo')
      expect(populator.states_to_cache).to eq(['al', 'hi'])
    end
  end

  context "#keys_to_cache" do
    it "should return all cache keys defined in class if value is all" do
      populator = CachePopulator::FooPopulator.new(values: 'al,ca', cache_keys: 'all')
      expect(populator.keys_to_cache).to eq(['foo', 'bar', 'baz'])
    end

    it "should return defined list of cache keys" do
      populator = CachePopulator::FooPopulator.new(values: 'al,ca', cache_keys: 'foo')
      expect(populator.keys_to_cache).to eq(['foo'])
    end
  end


  context "#run_with_validations" do
    it "raises PopulatorError if record not valid" do
      populator = CachePopulator::FooPopulator.new(values: 'all', cache_keys: 'unknown')
      expect { populator.run_with_validation }.to raise_error(CachePopulator::PopulatorError, "CachePopulator::FooPopulator cache failure: cache_keys must have the value 'all' or be a list of valid cache keys")
    end

    it "yields every combination of states and cache_keys" do
      populator = CachePopulator::FooPopulator.new(values: 'ak,hi', cache_keys: 'foo, baz')
      expect { |b| populator.run_with_validation(&b) }.to yield_successive_args(['ak', 'foo'], ['ak', 'baz'], ['hi', 'foo'], ['hi', 'baz'])
    end
  end
end
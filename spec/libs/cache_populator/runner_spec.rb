require "spec_helper"

describe CachePopulator::Runner do

  let(:rows) do
    [
      {"type" => "state", "values" => "ca,hi", "cache_keys" => "metrics"},
      {"type" => "city", "values" => "ca,hi:1,2,3", "cache_keys" => "school_levels"},
      {"type" => "school", "values" => "ca:1,2,3", "cache_keys" => "ratings"}
    ]
  end

  let(:subject) { CachePopulator::Runner.new(rows) }
  let(:row) { { 'type' => 'state', 'values' => 'ca,hi', 'cache_keys' => 'foo,bar'} }

  describe "#setup_cacher" do
    it "returns a StateCachePopulator if type = state" do
      cacher = subject.setup_cacher(row)
      expect(cacher).to be_a(CachePopulator::StateCachePopulator)
    end

    it "returns a CityCachePopulator if type = city" do
      row['type'] = 'city'
      cacher = subject.setup_cacher(row)
      expect(cacher).to be_a(CachePopulator::CityCachePopulator)
    end

    it "returns a DistrictCachePopulator if type = district" do
      row['type'] = 'district'
      cacher = subject.setup_cacher(row)
      expect(cacher).to be_a(CachePopulator::DistrictCachePopulator)
    end

    it "returns a SchoolCachePopulator if type = school" do
      row['type'] = 'school'
      cacher = subject.setup_cacher(row)
      expect(cacher).to be_a(CachePopulator::SchoolCachePopulator)
    end

    it "returns nil for unrecognized cacher types" do
      row['type'] = 'foo'
      expect(subject.setup_cacher(row)).to be_nil
    end
  end

  describe "#run" do
    it "should instantiate cache populator based on type" do
      state_populator = instance_double(CachePopulator::StateCachePopulator, run: 0, valid?: true)
      city_populator = instance_double(CachePopulator::CityCachePopulator, run: 0, valid?: true)
      school_populator = instance_double(CachePopulator::SchoolCachePopulator, run: 0, valid?: true)
      expect(CachePopulator::StateCachePopulator).to receive(:new).with(values: "ca,hi", cache_keys: "metrics").and_return(state_populator)
      expect(CachePopulator::CityCachePopulator).to receive(:new).with(values: "ca,hi:1,2,3", cache_keys: "school_levels").and_return(city_populator)
      expect(CachePopulator::SchoolCachePopulator).to receive(:new).with(values: "ca:1,2,3", cache_keys: "ratings").and_return(school_populator)
      subject.run
    end
  end

  describe "#run with errors" do
    let(:rows_with_errors) do
      [
        {"type" => "state", "values" => "ca,hi", "cache_keys" => "metrics"},
        {"type" => "city", "values" => "ca,hi:1,2,3", "cache_keys" => "school_levels"},
        {"type" => "foo", "values" => ":1,2,3", "cache_keys" => "ratings"}
      ]
    end

    it "fails fast" do
      runner = CachePopulator::Runner.new(rows_with_errors)
      expect { runner.run }.to raise_error(CachePopulator::PopulatorError, /Error on row 3: Cacher type not recognized/m)
    end
  end

  context ".populate_all_and_return_rows_changed" do
    it "returns an integer for numbers of rows updated" do
      allow_any_instance_of(CachePopulator::SchoolCachePopulator).to receive(:run).and_return(3)
      allow_any_instance_of(CachePopulator::StateCachePopulator).to receive(:run).and_return(2)
      allow_any_instance_of(CachePopulator::CityCachePopulator).to receive(:run).and_return(3)
      expect(CachePopulator::Runner.populate_all_and_return_rows_changed(rows)).to be_a(Integer)
      expect(CachePopulator::Runner.populate_all_and_return_rows_changed(rows)).to eq(8)
    end
  end


end
require "spec_helper"

describe CachePopulator::Runner do

  after { tempfile_1.unlink }
  let(:tempfile_1) do
    Tempfile.new('tsv').tap do |file|
      file << "type\tvalues\tcache_keys\n"
      file << "state\tca,hi\tstate_characteristics\n"
      file << "city\tca,hi:1,2,3\tschool_levels\n"
      file << "school\tca:1,2,3\tratings\n"
      file.close
    end
  end

  let(:tempfile_with_blank_lines) do
    open(tempfile_1) do |f|
      f << "\n"
      f << "\n"
    end
  end

  let(:subject) { CachePopulator::Runner.new(tempfile_1.path) }
  let(:line_as_hash) { { 'type' => 'state', 'values' => 'ca,hi', 'cache_keys' => 'foo,bar'} }

  describe "#setup_cacher" do
    it "returns a StateCachePopulator if type = state" do
      cacher = subject.setup_cacher(line_as_hash)
      expect(cacher).to be_a(CachePopulator::StateCachePopulator)
    end 

    it "returns a CityCachePopulator if type = city" do
      line_as_hash['type'] = 'city'
      cacher = subject.setup_cacher(line_as_hash)
      expect(cacher).to be_a(CachePopulator::CityCachePopulator)
    end 

    it "returns a DistrictCachePopulator if type = district" do
      line_as_hash['type'] = 'district'
      cacher = subject.setup_cacher(line_as_hash)
      expect(cacher).to be_a(CachePopulator::DistrictCachePopulator)
    end 

    it "returns a SchoolCachePopulator if type = school" do
      line_as_hash['type'] = 'school'
      cacher = subject.setup_cacher(line_as_hash)
      expect(cacher).to be_a(CachePopulator::SchoolCachePopulator)
    end 

    it "returns nil for unrecognized cacher types" do
      line_as_hash['type'] = 'foo'
      expect(subject.setup_cacher(line_as_hash)).to be_nil
    end
  end

  describe "#run" do

    it "should call respective cache populator class by line" do
      state_populator = instance_double(CachePopulator::StateCachePopulator, run: 0, valid?: true)
      city_populator = instance_double(CachePopulator::CityCachePopulator, run: 0, valid?: true)
      school_populator = instance_double(CachePopulator::SchoolCachePopulator, run: 0, valid?: true)
      expect(CachePopulator::StateCachePopulator).to receive(:new).with(values: "ca,hi", cache_keys: "state_characteristics").and_return(state_populator)
      expect(CachePopulator::CityCachePopulator).to receive(:new).with(values: "ca,hi:1,2,3", cache_keys: "school_levels").and_return(city_populator)
      expect(CachePopulator::SchoolCachePopulator).to receive(:new).with(values: "ca:1,2,3", cache_keys: "ratings").and_return(school_populator)
      subject.run
    end

    it "should ignore blank lines" do
      open(tempfile_1) do |f|
        f << "\n"
        f << "\n"
      end
      allow(subject).to receive(:run_instantiated_cachers).and_return(nil)
      subject.run
      expect(subject.instantiated_cachers.find{|k,v| v.is_a?(CachePopulator::PopulatorError)}).to be_nil
    end
  end

  describe "#run with errors" do

    after { tempfile_with_errors.unlink }

    let(:tempfile_with_errors) do
      Tempfile.new('tsv').tap do |file|
        file << "type\tvalues\tcache_keys\n"
        file << "state\tca,hi\tstate_characteristics\n"
        file << "city\tca,hi:1,2,3\tstate_characteristics\n"
        file << "foo\t:1,2,3\tratings\n"
        file.close
      end
    end

    it "fails fast" do
      runner = CachePopulator::Runner.new(tempfile_with_errors.path) 
      expect { runner.run }.to raise_error(CachePopulator::PopulatorError, /Error on line 3:.+Error on line 4/m)
    end
  end

  context ".populate_all_and_return_rows_changed" do
    it "returns an integer for numbers of rows updated" do
      allow_any_instance_of(CachePopulator::SchoolCachePopulator).to receive(:run).and_return(3)
      allow_any_instance_of(CachePopulator::StateCachePopulator).to receive(:run).and_return(2)
      allow_any_instance_of(CachePopulator::CityCachePopulator).to receive(:run).and_return(3)
      expect(CachePopulator::Runner.populate_all_and_return_rows_changed(tempfile_1)).to be_a(Integer)
      expect(CachePopulator::Runner.populate_all_and_return_rows_changed(tempfile_1)).to eq(8)
    end
  end

    
end
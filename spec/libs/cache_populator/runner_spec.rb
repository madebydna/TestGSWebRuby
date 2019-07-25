require "spec_helper"

describe CachePopulator::Runner do

    after { tempfile_1.unlink }
    let(:tempfile_1) do
        Tempfile.new('tsv').tap do |file|
            file << "type\tvalues\tcache_keys\n"
            file << "state\tca,hi\tstate_characteristics\n"
            file << "city\tca,hi:1,2,3\tschool_levels\n"
            file << "school\t:1,2,3\tratings\n"
            file.close
        end
    end

    let(:subject) { CachePopulator::Runner.new(tempfile_1.path) }
    let(:line_as_hash) { { 'type' => 'state', 'values' => 'ca,hi', 'cache_keys' => 'foo,bar'} }

    context "#setup_cacher" do
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

    context "#run" do

        it "should call respective cache populator class by line" do
            state_populator = instance_double(CachePopulator::StateCachePopulator, run: true, valid?: true)
            city_populator = instance_double(CachePopulator::CityCachePopulator, run: true, valid?: true)
            school_populator = instance_double(CachePopulator::SchoolCachePopulator, run: true, valid?: true)
            expect(CachePopulator::StateCachePopulator).to receive(:new).with(values: "ca,hi", cache_keys: "state_characteristics").and_return(state_populator)
            expect(CachePopulator::CityCachePopulator).to receive(:new).with(values: "ca,hi:1,2,3", cache_keys: "school_levels").and_return(city_populator)
            expect(CachePopulator::SchoolCachePopulator).to receive(:new).with(values: ":1,2,3", cache_keys: "ratings").and_return(school_populator)
            subject.run
        end
    end

    context "#run with errors" do

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

    
end
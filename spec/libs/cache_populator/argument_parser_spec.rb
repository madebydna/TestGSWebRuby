require 'spec_helper'

describe CachePopulator::ArgumentParser do
  subject { CachePopulator::ArgumentParser.new }
  
  describe '#parse' do
    
    context "with the -h or --help flag" do
      let(:help) { %r(Usage: rails runner script\/populate_cache_tables \[options\]) }

      it "prints the usage text and exits" do
        expect do
          expect { subject.parse(['-h']) }.to output(help).to_stdout
        end.to raise_error(SystemExit)
    
        expect do
          expect { subject.parse(['--help']) }.to output(help).to_stdout
        end.to raise_error(SystemExit)
      end
    end

    context 'with the -f or --file flag' do
      after { tempfile_1.unlink }
      let(:tempfile_1) do
        Tempfile.new('tsv').tap do |file|
          file << "type\tvalues\tcache_keys\n"
          file << "state\tca,hi\tall\n"
          file << "city\t:1,2,3\tschool_levels\n"
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

      let(:expected_commands) {
        [
          {"type" => "state", "values" => "ca,hi", "cache_keys" => "all"},
          {"type" => "city", "values" => ":1,2,3", "cache_keys" => "school_levels"},
          {"type" => "school", "values" => "ca:1,2,3", "cache_keys" => "ratings"}
        ]
      }

      it "parses lines from the file as set of commands" do
        expect(subject.parse(['-f', tempfile_1.path])).to eq(expected_commands)
      end

      it "ignores blank lines" do
        expect(subject.parse(['--file', tempfile_with_blank_lines.path])).to eq(expected_commands)
      end
    end

    context 'with the -c or --city flag' do
      it "parses argument according to format states:cache_keys:city_ids" do 
        expect(subject.parse(['--city', 'ca,hi:school_levels'])).to eq([{"type" => "city", "values" => "ca,hi", "cache_keys" => "school_levels"}])
      end

      it "creates command to update all cities and all cache keys given 'all' value" do
        expect(subject.parse(['-c', 'all'])).to eq([{"type" => "city", "values" => "all", "cache_keys" => "all"}])
      end
    end


    context 'with the -d or --district flag' do
      it "parses argument according to format states:cache_keys:district_ids_or_sql" do 
        expect(subject.parse(['--district', 'ca:school_levels:1,2,3'])).to eq([{"type" => "district", "values" => "ca:1,2,3", "cache_keys" => "school_levels"}])
      end

      it "creates command to update all districts and all cache keys given 'all' value" do
        expect(subject.parse(['-d', 'all'])).to eq([{"type" => "district", "values" => "all", "cache_keys" => "all"}])
      end
    end


    context 'with the -s or --school flag' do
      it "parses argument according to format states:cache_keys:school_ids_or_sql" do 
        expect(subject.parse(['--school', 'de:all:id IN (9,18,23)'])).to eq([{"type" => "school", "values" => "de:id IN (9,18,23)", "cache_keys" => "all"}])
      end

      it "creates command to update all schools and all cache keys given 'all' value" do
        expect(subject.parse(['-s', 'all'])).to eq([{"type" => "school", "values" => "all", "cache_keys" => "all"}])
      end
    end


    context 'with the -t or --state flag' do
      it "parses argument according to format states:cache_keys:district_ids_or_sql" do 
        expect(subject.parse(['--state', 'de,ny:all'])).to eq([{"type" => "state", "values" => "de,ny", "cache_keys" => "all"}])
      end

      it "creates command to update all states and all cache keys given 'all' value" do
        expect(subject.parse(['-t', 'all'])).to eq([{"type" => "state", "values" => "all", "cache_keys" => "all"}])
      end
    end


  end

end
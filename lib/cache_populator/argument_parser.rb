require 'csv'
module CachePopulator
  class ArgumentParser

    attr_reader :parsed_options
    def initialize
      @parsed_options = {commands: []}
    end
    
    def parse(args)
      begin
        OptionParser.new do |opts|
          opts.banner = "Usage: rails runner script/populate_cache_tables [options]"
          opts.on("-f", "--file FILE", "TSV file with 'type', 'values', and 'cache_keys' as headers") do |file|
            parsed_options[:file] = file
          end
          opts.on("-c", "--city STRING", String, "Format states:cache_keys:city_ids") do |args|
            parsed_options[:commands] <<  handle_args('city', args)
          end
          opts.on("-d", "--district STRING", String, "Format states:cache_keys:district_ids_or_sql") do |args|
            parsed_options[:commands] <<  handle_args('district', args)
          end
          opts.on("-s", "--school STRING", String, "Format states:cache_keys:school_ids_or_sql") do |args|
            parsed_options[:commands] <<  handle_args('school', args)
          end
          opts.on("-t", "--state STRING", String, "Format states:cache_keys") do |args|
            parsed_options[:commands] <<  handle_args('state', args)
          end
          opts.on("-e", "--examples", "Show basic usage examples") {puts usage; exit}
          opts.on_tail("-h", "--help", "Show this message") { puts "Hello!"; puts opts; exit }
        end.parse!(args)

        
        parse_file_to_commands if parsed_options[:file].present?

        parsed_options[:commands]
      rescue OptionParser::MissingArgument => e
        puts e.message
        exit
      end
    end

    def parse_file_to_commands
      CSV.foreach(parsed_options[:file], headers: true, col_sep: "\t", quote_char: "\x00") do |line|
        next if line.blank?
        hash = {}
        hash['type'] = line['type']
        hash['values'] = line['values']
        hash['cache_keys'] = line['cache_keys']
        parsed_options[:commands] << hash
      end
    end

    private
    def handle_args(type, _args)
      return nil unless _args.present?
      result = { 'type' => type }
      if _args == "all"
        result['values'] = 'all'
        result['cache_keys'] = 'all'
      else
        states,cache_keys,optional_ids = _args.split(':')
        values = states
        values += ":#{optional_ids}" if optional_ids.present?
        result['values'] = values
        result['cache_keys'] = cache_keys
      end
      result
    end

    def usage
      <<~USAGE
        \e[1mUSAGE EXAMPLES\e[22m
        \e[1mFILE\e[22m
        \trails runner script/populate_cache_tables.rb -f path/to/tsv_files
        \e[1mSCHOOL\e[22m
        \trails runner script/populate_cache_tables.rb -s de:all:9,18,23
        \trails runner script/populate_cache_tables.rb -s al:test_scores_gsdata
        \e[1mDISTRICT\e[22m
        \trails runner script/populate_cache_tables.rb -d al:feed_test_scores_gsdata
        \trails runner script/populate_cache_tables.rb -d de:all:9,18,23
        \e[1mCITY\e[22m
        \trails runner script/populate_cache_tables.rb -c al:school_levels :all:8,9
        \trails runner script/populate_cache_tables.rb -c :all:8,9
        \e[1mSTATE\e[22m
        \trails runner script/populate_cache_tables.rb -t fl:state_characteristics
        \trails runner script/populate_cache_tables.rb -t all

      USAGE
    end

  end
end
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

  end
end
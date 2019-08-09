require 'csv'

module CachePopulator
	class Runner

		CACHER_TYPES = {
			"state" => StateCachePopulator,
			"city" => CityCachePopulator,
			"district" => DistrictCachePopulator,
			"school" => SchoolCachePopulator
		}

		attr_accessor :file, :instantiated_cachers, :rows_updated
		def initialize(file)
			@file = file
			@rows_updated = 0
		end

		def self.populate_all_and_return_rows_changed(file)
			populator = self.new(file)
			populator.run
			populator.rows_updated
		end

		def run
			@instantiated_cachers = {}
			CSV.foreach(file, headers: true, col_sep: "\t", quote_char: "\x00") do |line|
				next if line.blank?
				cacher = setup_cacher(line)
				if cacher.blank?
						instantiated_cachers[$INPUT_LINE_NUMBER] = PopulatorError.new("Cacher type not recognized: #{line['type']}. Type must be one of: #{CACHER_TYPES.keys.join(', ')}.")
				elsif cacher.valid?
						instantiated_cachers[$INPUT_LINE_NUMBER] = cacher
				else 
						instantiated_cachers[$INPUT_LINE_NUMBER] = PopulatorError.new("#{cacher.class} cache failure: #{cacher.print_errors}")
				end
			end
			run_instantiated_cachers
		end

		def run_instantiated_cachers
			if instantiated_cachers.values.any? {|value| value.is_a?(PopulatorError) }
				error_messages = instantiated_cachers.select {|k,v| v.is_a?(PopulatorError) }.map do |k, v|
					"Error on line #{k}: #{v.message}"
				end
					# Combine different error messages into one 
					raise PopulatorError.new("The input file has errors:\n" + error_messages.join("\n"))
			else
				instantiated_cachers.each do |lineno, cacher| 
					begin
						@rows_updated += cacher.run
					rescue => e
						# puts "Error raised from #{cacher.class} cacher on line #{lineno}: #{e.message}"
						raise StandardError.new("Error raised from #{cacher.class} cacher on line #{lineno}: #{e.message}")
					end
				end
			end
		end

		def setup_cacher(line)
			type = line["type"]
			cacher = CACHER_TYPES[type]
			if cacher.present?
					cacher.send(:new, values: line["values"], cache_keys: line["cache_keys"])
			end
		end
	end
end
require 'csv'

module CachePopulator
	class Runner

		CACHER_TYPES = {
			"state" => StateCachePopulator,
			"city" => CityCachePopulator,
			"district" => DistrictCachePopulator,
			"school" => SchoolCachePopulator
		}

		attr_accessor :rows, :instantiated_cachers, :rows_updated
		def initialize(rows)
			@rows = rows
			@rows_updated = 0
		end

		def self.populate_all_and_return_rows_changed(rows)
			populator = self.new(rows)
			populator.run
			populator.rows_updated
		end

		def run
			@instantiated_cachers = {}
      rows.each_with_index do |row, i|
				cacher = setup_cacher(row)
				if cacher.blank?
						instantiated_cachers[i+1] = PopulatorError.new("Cacher type not recognized: #{row['type']}. Type must be one of: #{CACHER_TYPES.keys.join(', ')}.")
				elsif cacher.valid?
						instantiated_cachers[i+1] = cacher
				else 
						instantiated_cachers[i+1] = PopulatorError.new("#{cacher.class} cache failure: #{cacher.print_errors}")
				end
			end
			run_instantiated_cachers
		end

		def run_instantiated_cachers
			if instantiated_cachers.values.any? {|value| value.is_a?(PopulatorError) }
				error_messages = instantiated_cachers.select {|k,v| v.is_a?(PopulatorError) }.map do |k, v|
					"Error on row #{k}: #{v.message}"
				end
					# Combine different error messages into one 
					raise PopulatorError.new("The input file has errors:\n" + error_messages.join("\n"))
			else
				instantiated_cachers.each do |lineno, cacher| 
					begin
						@rows_updated += cacher.run
					rescue => e
						raise StandardError.new("Error raised from #{cacher.class} cacher on line #{lineno}: #{e.message}")
					end
				end
			end
		end

		def setup_cacher(row)
			type = row["type"]
			cacher = CACHER_TYPES[type]
			if cacher.present?
				cacher.send(:new, values: row["values"], cache_keys: row["cache_keys"])
			end
		end
	end
end
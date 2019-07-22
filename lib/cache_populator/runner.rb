require 'csv'

module CachePopulator
    class Runner

        CACHER_TYPES = {
            "state" => StateCachePopulator,
            "city" => CityCachePopulator,
            "district" => DistrictCachePopulator,
            "school" => SchoolCachePopulator
        }

        attr_accessor :file
        def initialize(file)
            @file = file
        end

        def self.populate_all(file)
            populator = self.new(file)
            populator.run
        end

        def run
            CSV.foreach(file, headers: true, col_sep: "\t", quote_char: "\x00") do |line|
                cacher = setup_cacher(line)
                cacher.run
            end
        end

        def setup_cacher(line)
            type = line["type"]
            cacher = CACHER_TYPES[type]
            if cacher.blank?
                raise PopulatorError.new("Cacher type not recognized: #{type}. Type must be one of state, city, district, or school.")
            else
                cacher.send(:new, values: line["values"], cache_keys: line["cache_keys"])
            end
        end
    end
end
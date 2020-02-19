# frozen_string_literal: true

require_relative './characteristics_caching/characteristics_builder'

module Feeds
  module Directory
    class DistrictDataReader
      include Feeds::FeedConstants
      include Feeds::FeedHelper

      DIRECTORY_FEED_DISTRICT_CACHE_KEYS = %w(district_directory feed_district_characteristics gsdata)

      attr_reader :state, :district

      def initialize(state, district)
        @state = state
        @district = district
      end

      def universal_id
        @_universal_id ||= begin
          transpose_universal_id(state, district, 'district').to_i.to_s
        end
      end

      def census_info
        @_census_info ||= begin
          data_builder = CharacteristicsBuilder.new(district_cache, universal_id, 'district')
          data_builder.data_hashes
        end
      end

      def level
        level_value = data_value('level')

        if level_value == 'Ungraded'
          level_value =  'n/a'
        elsif level_value.present?
          level_value.slice! ' & Ungraded'
        end
        level_value
      end

      def data_value(key)
        data_set = district_cache.fetch(key, nil)
        raise StandardError("Missing Cache Key") unless data_set
        data_set.first["district_value"]
      end

      def district_cache
        @_district_cache ||= begin
          district_caches = Array.wrap(DistrictCache.for_district(district).include_cache_keys(DIRECTORY_FEED_DISTRICT_CACHE_KEYS))
          district_caches.reduce({}) do |accum, district_cache|
            json_district_cache = JSON.parse(district_cache&.value)
            next accum unless json_district_cache
            accum = accum.merge(json_district_cache)
            accum
          end
        end
      end
    end
  end
end
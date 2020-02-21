# frozen_string_literal: true

require_relative './characteristics_caching/characteristics_builder'

module Feeds
  module Directory
    class DistrictDataReader
      include Feeds::FeedConstants
      include Feeds::FeedHelper

      DIRECTORY_FEED_DISTRICT_CACHE_KEYS = %w(district_directory feed_district_characteristics gsdata)

      # array of methods used by the data reader to output data
      DISTRICT_ATTRIBUTES_METHODS = %w(universal_id level web_site state zip)

      # array of cache keys used to retrieve data from the caches
      DISTRICT_ATTRIBUTES_CACHE_METHODS = %w(description FIPScounty level_code home_page_url url)

      attr_reader :state, :district

      def initialize(state, district)
        @state = state.upcase
        @district = district
      end

      def universal_id
        @_universal_id ||= begin
          transpose_universal_id(state, district, 'district').to_s
        end
      end

      def zip
        @_zip ||= district.zipcode
      end

      def census_info
        @_census_info ||= begin
          data_builder = CharacteristicsBuilder.new(district_cache, universal_id, 'district')
          data_builder.data_hashes
        end
      end

      def data_values
        @_data_values ||= begin
          district_attributes_hash = DIRECTORY_DISTRICT_ATTRIBUTES.each_with_object({}) do |attribute, hash|
            if DISTRICT_ATTRIBUTES_METHODS.include?(attribute)
              hash[attribute.gsub('_','-')] = send(attribute.to_sym)
            elsif DISTRICT_ATTRIBUTES_CACHE_METHODS.include?(attribute)
              hash[attribute.gsub('_','-')] = data_value(attribute)
            else
              hash[attribute.gsub('_','-')] = district.send(attribute.to_sym)
            end
          end

          district_attributes_hash.merge(census_info)
        end
      end

      def web_site
        @_web_site ||=begin
          data_value('home_page_url')
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
            accum.merge(JSON.parse(district_cache.value))
          end
        end
      end
    end
  end
end
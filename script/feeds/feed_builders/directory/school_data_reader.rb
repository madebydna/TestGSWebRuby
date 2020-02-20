# frozen_string_literal: true

require_relative './characteristics_caching/characteristics_builder'

module Feeds
  module Directory
    class SchoolDataReader
      include Feeds::FeedConstants
      include Feeds::FeedHelper

      DIRECTORY_FEED_SCHOOL_CACHE_KEYS = %w(directory feed_characteristics gsdata)

      # array of methods used by the data reader to output data
      SCHOOL_ATTRIBUTES_METHODS = %w(universal_id state_id level universal_district_id web_site)

      # array of cache keys used to retrieve data from the caches
      SCHOOL_ATTRIBUTES_CACHE_METHODS = %w(description FIPScounty level_code district_name url)

      attr_reader :state, :school

      def initialize(state, school)
        @state = state
        @school = school
      end

      def universal_id
        @_universal_id ||= begin
          transpose_universal_id(state, school, 'school').to_s
        end
      end

      def census_info
        @_census_info ||= begin
          data_builder = CharacteristicsBuilder.new(school_cache, universal_id, 'school')
          data_builder.data_hashes
        end
      end

      def data_values
        @_data_values ||= begin
          state_attributes_hash = DIRECTORY_SCHOOL_ATTRIBUTES.each_with_object({}) do |attribute, hash|
            if SCHOOL_ATTRIBUTES_METHODS.include?(attribute)
              hash[attribute.gsub('_','-')] = send(attribute.to_sym)
            elsif SCHOOL_ATTRIBUTES_CACHE_METHODS.include?(attribute)
              hash[attribute.gsub('_','-')] = data_value(attribute)
            else
              hash[attribute.gsub('_','-')] = school.send(attribute.to_sym)
            end
          end

          census_data_hash = census_info.each_with_object({}) do |data_object, data_hash|
            key = data_object.keys.first
            value = data_object.values.first
            data_hash[key] = value
          end

          state_attributes_hash.merge(census_data_hash)
        end
      end

      def state_id
        @_state_id ||=begin
          transpose_universal_id(state, nil, 'state')
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

      def web_site
        @_web_site ||=begin
          data_value('home_page_url')
        end
      end

      def universal_district_id
        @_universal_district_id ||= begin
          '1' + state_fips[state.upcase] + school.district_id.to_s.rjust(5, '0')
        end
      end

      def data_value(key)
        data_set = school_cache.fetch(key, nil)
        raise StandardError.new("Missing Cache Key: School:#{school.id} Key:#{key}") unless data_set
        data_set.first["school_value"]
      end

      def school_cache
        @school_cache ||= begin
          school_caches = Array.wrap(SchoolCache.where(name: DIRECTORY_FEED_SCHOOL_CACHE_KEYS, school_id: school.id, state: state))
          school_caches.reduce({}) do |accum, school_cache|
            json_school_cache = JSON.parse(school_cache&.value)
            next accum unless json_school_cache
            accum = accum.merge(json_school_cache)
            accum
          end
        end
      end
    end
  end
end
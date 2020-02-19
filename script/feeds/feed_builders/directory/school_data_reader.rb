# frozen_string_literal: true

require_relative './characteristics_caching/characteristics_builder'

module Feeds
  module Directory
    class SchoolDataReader
      include Feeds::FeedConstants
      include Feeds::FeedHelper

      DIRECTORY_FEED_SCHOOL_CACHE_KEYS = %w(directory feed_characteristics gsdata)

      attr_reader :state, :school

      def initialize(state, school)
        @state = state
        @school = school
      end

      def universal_id
        @_universal_id ||= begin
          transpose_universal_id(state, school, 'school').to_i.to_s
        end
      end

      def census_info
        @_census_info ||= begin
          data_builder = CharacteristicsBuilder.new(school_cache, universal_id, 'school')
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
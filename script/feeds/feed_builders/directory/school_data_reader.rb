# frozen_string_literal: true

require_relative './characteristics_caching/characteristics_builder'

module Feeds
  module Directory
    class SchoolDataReader
      include Feeds::FeedConstants
      include Feeds::FeedHelper

      DIRECTORY_FEED_SCHOOL_CACHE_KEYS = %w(directory feed_characteristics gsdata)

      # array of methods used by the data reader to output data
      SCHOOL_ATTRIBUTES_DATA_READER_METHODS = %w(universal_id level universal_district_id web_site zip)

      # array of cache keys used to retrieve data from the caches
      SCHOOL_ATTRIBUTES_CACHE_METHODS = %w(description FIPScounty level_code district_name url school_summary)

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
          all_attributes = DIRECTORY_SCHOOL_ATTRIBUTES + (["school_summary"])
          all_attributes.each_with_object({"entity" => "school", "gs-id" => school.id}) do |attribute, hash|
            cache_key = attribute.gsub('_','-').downcase
            if SCHOOL_ATTRIBUTES_DATA_READER_METHODS.include?(attribute)
              hash[cache_key] = send(attribute.to_sym)
            elsif SCHOOL_ATTRIBUTES_CACHE_METHODS.include?(attribute)
              hash[cache_key] = data_value(attribute)
            else
              hash[cache_key] = school.send(attribute.to_sym).presence
            end
          end
        end
      end

      def level
        @_level ||=begin
          level_value = data_value('level')

          if level_value == 'Ungraded'
            level_value =  'n/a'
          elsif level_value.present?
            level_value.slice! ' & Ungraded'
          end
          level_value
        end
      end

      def web_site
        @_web_site ||= data_value('home_page_url')
      end

      def zip
        @_zip ||= school.zipcode
      end

      def universal_district_id
        @_universal_district_id ||= begin
          '1' + state_fips[state.upcase] + school.district_id.to_s.rjust(5, '0')
        end
      end

      def data_value(key)
        data_set = school_cache.fetch(key, nil)
        raise StandardError.new("Missing Cache Key: State:#{state} School:#{school.id} Key:#{key}") unless data_set
        data_set.first["school_value"]
      end

      def school_cache
        @school_cache ||= begin
          school_caches = Array.wrap(SchoolCache.where(name: DIRECTORY_FEED_SCHOOL_CACHE_KEYS, school_id: school.id, state: state))
          school_caches.reduce({}) do |accum, school_cache|
            accum.merge(JSON.parse(school_cache.value))
          end
        end
      end
    end
  end
end
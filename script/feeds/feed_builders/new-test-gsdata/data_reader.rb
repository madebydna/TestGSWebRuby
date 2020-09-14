# frozen_string_literal: true

module Feeds
  module NewTestGsdata
    class DataReader
      attr_reader :state, :schools, :districts
# rubocop:disable Layout/SpaceInsideArrayLiteralBrackets, MultilineArrayBraceLayout
      BLACKLIST_BREAKDOWNS_REGEX = [    /Learners Enrolled/,
                                        /Fluent-English/,
                                        /Initially-Fluent/,
                                        /Proficient Former/,
                                        /Proficient Current/,
                                        /General-Education/,
                                        /Parents/,
                                        /Reclassified/,
                                        /Migrant/,
                                        /migrant/,
                                        /Homeless/,
                                        /Free lunch/,
                                        /Reduced lunch/,
                                        /Title I/,
                                        /Poverty/,
                                        /poverty/,
                                        /LEP/,
                                        /Gender Unknown/,
                                        /General population/,
                                        /Unspecified/,
                                        /Gifted/
      ]
# rubocop:enable Layout/SpaceInsideArrayLiteralBrackets, MultilineArrayBraceLayout
      def initialize(state, schools, districts)
        @state = state
        @schools = schools
        @districts = districts
      end

      def each_state_test(&block)
        state_test_info.each(&block)
      end

      def each_state_result_for_test_name(test_name)
        state_cache = StateCache.for_state('feed_test_scores_gsdata', @state)
        raise "State cache not found for #{@state}" unless state_cache
        cache_hash = state_cache.cache_data
        yield cache_hash[test_name]&.select(&cache_filter)
      end

      def each_district_result_for_test_name(test_name)
        district_ids.each do |district_id|
          district_cache = DistrictCache.where(state: @state, district_id: district_id, name: 'feed_test_scores_gsdata').first
          next unless district_cache.present?
          district_id = district_cache.district_id
          test_hash = district_cache.cache_data
          next unless test_hash[test_name].present?
          yield test_hash[test_name]&.select(&cache_filter), district_id
        end
      end

      def district_data_for_test_name?(test_name)
        district_ids.each do |district_id|
          district_cache = DistrictCache.where(state: @state, district_id: district_id, name: 'feed_test_scores_gsdata').first
          if district_cache.present? &&
              district_cache.cache_data[test_name].present? &&
              district_cache.cache_data[test_name].select(&cache_filter)
            return true
          end
        end
        return false
      end

      def each_school_result_for_test_name(test_name)
        school_ids.each do |school_id|
          school_cache = SchoolCache.where(state: @state, school_id: school_id, name: 'feed_test_scores_gsdata').first
          next unless school_cache.present?
          school_id = school_cache.school_id
          test_hash = school_cache.cache_data
          next unless test_hash[test_name].present?
          yield test_hash[test_name].select(&cache_filter), school_id
        end
      end

      def school_data_for_test_name?(test_name)
        school_ids.each do |school_id|
          school_cache = SchoolCache.where(state: @state, school_id: school_id, name: 'feed_test_scores_gsdata').first
          if school_cache.present? &&
              school_cache.cache_data[test_name].present? &&
              school_cache.cache_data[test_name].select(&cache_filter)
            return true
          end
        end
        return false
      end

      def each_school_result
        school_ids.each do |school_id|
          school_cache = SchoolCache.where(state: @state, school_id: school_id, name: 'feed_old_test_scores_gsdata').first
          next unless school_cache.present?
          school_id = school_cache.school_id
          test_hash = school_cache.cache_data
          test_hash.each do |(test_name, hash_arr)|
            hash_arr.select(&cache_filter).each do |hash|
              yield(hash.merge({
                                   'test-name' => test_name,
                                   'school-id' => school_id
                               }))
            end
          end
        end
      end

      private

      def school_ids
        @schools.map(&:school_id)
      end

      def district_ids
        @districts.map(&:district_id)
      end

      def state_test_info
        @_state_test_info ||= begin
          state_cache = StateCache.for_state('feed_test_description_gsdata', @state)
          raise "State test cache not found for feed_test_description_gsdata #{@state}" unless state_cache
          state_cache.cache_data
        end
      end

      def cache_filter
        lambda do |h|
          # ! h['breakdowns'].match(Regexp.union(BLACKLIST_BREAKDOWNS_REGEX))
          BLACKLIST_BREAKDOWNS_REGEX.none? { |regex| regex.match?(h['breakdowns']) }
        end
      end
    end
  end
end

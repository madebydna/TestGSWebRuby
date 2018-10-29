# frozen_string_literal: true

module Feeds
  module OldTestGsdata
    class DataReader
      attr_reader :state, :schools, :districts

      def initialize(state, schools, districts)
        @state = state
        @schools = schools
        @districts = districts
      end

      def each_state_test(&block)
        state_test_info.each(&block)
      end

      def each_state_result
        state_cache = StateCache.for_state('feed_test_scores_gsdata', @state)
        raise "State cache not found for #{@state}" unless state_cache
        cache_hash = state_cache.cache_data
        cache_hash.each do |(test_name, hash_arr)|
          hash_arr.select(&cache_filter).each do |hash|
            yield hash.merge({'test-name' => test_name})
          end
        end
      end

      def each_district_result
        district_ids.each do |district_id|
          district_cache = DistrictCache.where(state: @state, district_id: district_id, name: 'feed_test_scores_gsdata').first
          next unless district_cache.present?
          test_hash = district_cache.cache_data
          test_hash.each do |(test_name, hash_arr)|
            hash_arr.select(&cache_filter).each do |hash|
              yield hash.merge({
                                   'test-name' => test_name,
                                   'district-id' => district_id
                               })
            end
          end
        end
      end

      def each_school_result
        school_ids.each do |school_id|
          school_cache = SchoolCache.where(state: @state, school_id: school_id, name: 'feed_old_test_scores_gsdata').first
          next unless school_cache.present?
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
        @schools.map(&:id)
      end

      def district_ids
        @districts.map(&:id)
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
          breakdown = h['breakdowns']
          if breakdown =~ /Learners Enrolled/ ||
              breakdown =~ /Fluent-English/ ||
              breakdown =~ /Initially-Fluent/ ||
              breakdown =~ /Proficient Former/ ||
              breakdown =~ /Proficient Current/ ||
              breakdown =~ /General-Education/ ||
              breakdown =~ /Parents/ ||
              breakdown =~ /Reclassified/ ||
              breakdown =~ /Migrant/ ||
              breakdown =~ /migrant/ ||
              breakdown =~ /Homeless/ ||
              breakdown =~ /Free lunch/ ||
              breakdown =~ /Reduced lunch/ ||
              breakdown =~ /Title I/ ||
              breakdown =~ /Poverty/ ||
              breakdown =~ /poverty/ ||
              breakdown =~ /LEP/ ||
              breakdown =~ /Gender Unknown/ ||
              breakdown =~ /General population/ ||
              breakdown =~ /Unspecified/ ||
              breakdown =~ /Gifted/
            false
          else
            true
          end
        end
      end
    end
  end
end

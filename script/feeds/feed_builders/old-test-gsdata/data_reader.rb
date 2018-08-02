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
        DistrictCache.where(name: 'feed_test_scores_gsdata', district_id: district_ids, state: @state).find_each(batch_size: 100) do |district_cache|
          district_id = district_cache.district_id
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
        SchoolCache.where(name: 'feed_old_test_scores_gsdata', school_id: school_ids, state: state).find_each(batch_size: 100) do |school_cache|
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
        @schools.map(&:id)
      end

      def district_ids
        @districts.map(&:id)
      end

      def state_test_info
        @_state_test_info ||= begin
          state_info = {}
          each_school_result do |hash|
            state_info[hash['test-id']] ||= {}
            test_hash = state_info[hash['test-id']]
            test_hash['test-id'] = hash['test-id']
            test_hash['test-name'] = hash['test-name']
            test_hash['test-abbr'] = hash['test-abbr']
            test_hash['scale'] ||= {}
            if hash['composite-of-pro-null'] == 1
              test_hash['scale'][hash['proficiency-band-name']] = 1
            end
            test_hash['most-recent-year'] = hash['year'] unless state_info[hash['test-id']]['most-recent-year'] && state_info[hash['test-id']]['most-recent-year'] > hash['year']
            test_hash['description'] = hash['description']
          end
          state_info.each do |(_, hash)|
            bands = hash['scale'].keys
            scale = bands.size < 3 ? bands.join(' or ') : bands.join(', ')
            hash['scale'] = "% #{scale}"
          end
          state_info.values
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

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

      def each_state_result(&block)
        state_caches.each(&block)
      end

      def each_district_result(&block)
        district_caches.each(&block)
      end

      def each_school_result(&block)
        school_caches.each(&block)
      end

      private

      def school_ids
        puts @schools.map(&:id).join(',')
        @schools.map(&:id)
      end

      def district_ids
        @districts.map(&:id)
      end

      def state_test_info
        @_state_test_info ||= begin
          state_info = school_caches.each_with_object({}) do |hash, info|
            info[hash['test-id']] ||= {}
            info[hash['test-id']]['test-id'] = hash['test-id']
            info[hash['test-id']]['test-name'] = hash['test-name']
            info[hash['test-id']]['test-abbr'] = hash['test-abbr']
            info[hash['test-id']]['scale'] ||= {}
            if hash['composite-of-pro-null'] == 1
              info[hash['test-id']]['scale'][hash['proficiency-band-name']] = 1
            end
            info[hash['test-id']]['most-recent-year'] = hash['year'] unless info[hash['test-id']]['most-recent-year'] && info[hash['test-id']]['most-recent-year'] > hash['year']
            info[hash['test-id']]['description'] = hash['description']
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
              breakdown =~ /General-Education/ ||
              breakdown =~ /Parents/ ||
              breakdown =~ /Reclassified/ ||
              breakdown =~ /Migrant/
            false
          else
            true
          end
        end
      end

      def school_caches
        @_school_caches ||= begin
          cache_hash = SchoolCache.for_schools_keys('feed_old_test_scores_gsdata', school_ids, @state)
          final_hashes = cache_hash.sort.each_with_object([]) do |(school_id, test_hash), output|
            test_hash['feed_old_test_scores_gsdata'].each do |test_name, hash_arr|
              augmented_hashes = hash_arr.select(&cache_filter).map do |hash|
                hash.merge({
                               'test-name' => test_name,
                               'school-id' => school_id
                           })
              end
              output.concat(augmented_hashes)
            end
          end
          final_hashes
        end
      end

      def district_caches
        @_district_caches ||= begin
          cache_hash = DistrictCache.for_districts_keys('feed_test_scores_gsdata', district_ids, @state)
          final_hashes = cache_hash.sort.each_with_object([]) do |(district_id, test_hash), output|
            test_hash['feed_test_scores_gsdata'].each do |test_name, hash_arr|
              augmented_hashes = hash_arr.select(&cache_filter).map do |hash|
                hash.merge({
                    'test-name' => test_name,
                    'district-id' => district_id
                           })
              end
              output.concat(augmented_hashes)
            end
          end
          final_hashes
        end
      end

      def state_caches
        @_state_caches ||= begin
          state_cache = StateCache.for_state('feed_test_scores_gsdata', @state)
          raise "State cache not found for #{@state}" unless state_cache
          cache_hash = state_cache.cache_data
          final_hashes = cache_hash.each_with_object([]) do |(test_name, hash_arr), output|
            augmented_hashes = hash_arr.select(&cache_filter).map do |hash|
              hash.merge({'test-name' => test_name})
            end
            output.concat(augmented_hashes)
          end
          final_hashes
        end
      end
    end
  end
end

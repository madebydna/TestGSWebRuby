# frozen_string_literal: true

module Feeds
  module OfficialOverallRating
    class DataReader
      include Rails.application.routes.url_helpers
      include UrlHelper
      include Feeds::FeedConstants
      include Feeds::FeedHelper

      attr_reader :state, :schools

      RATING_IDS = {
          'Test Score Rating' => 164,
          'Summary Rating' => 174
      }

      def initialize(state, schools, _)
        @state = state
        @schools = schools
        @state_data = JSON.parse(StateCache.for_state('feed_ratings', @state)&.value)
        @rating_type = @state_data['type']
      end

      def default_url_options
        { trailing_slash: true, protocol: 'https', host: 'www.greatschools.org', port: nil }
      end

      def each_result(&block)
        results.each(&block)
      end

      def state_results
        {}.tap do |hash|
          hash['id'] = test_type_to_id
          hash['year'] = @state_data['year']
          hash['description'] = @state_data['description']
        end
      end

      def test_type_to_id
        @_test_type_to_id ||= begin
            @state.upcase + RATING_IDS[@rating_type].to_s.rjust(5, "0")
        end
      end

      def school_rating(school)
        @rating_type == 'Summary Rating' ?  school.overall_gs_rating : school.test_scores_rating
      end

      def results
        ratings_hashes
      end

      def school_ids
        @schools.map(&:school_id)
      end

      def ratings_hashes
        @_ratings_hashes ||= begin
          ratings_caches.map do |school|
            {
                'universal-id' => school_uid(school.school_id),
                'test-rating-id' => test_type_to_id,
                'rating' => school_rating(school),
                'url' => school_url(school)
            }
          end
        end
      end

      def ratings_caches
        @_ratings_caches ||= begin
          query = SchoolCacheQuery.new(true).include_cache_keys('ratings').include_schools(@state, school_ids)
          query_results = query.query_and_use_cache_keys
          school_cache_results = SchoolCacheResults.new('ratings', query_results, true)
          school_cache_results.decorate_schools(schools)
        end
      end

      private

      def school_uid(id)
        transpose_universal_id(@state, Struct.new(:id).new(id), ENTITY_TYPE_SCHOOL)
      end

      def state_uid
        transpose_universal_id(@state, nil, nil)
      end
    end
  end
end

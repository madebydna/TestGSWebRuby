# frozen_string_literal: true

module Feeds
  module OfficialOverallRating
    class DataReader
      include Rails.application.routes.url_helpers
      include UrlHelper
      include Feeds::FeedConstants
      include Feeds::FeedHelper
      include CachedRatingsMethods

      attr_reader :state, :schools

      RATING_IDS = {
          'Test Score Rating' => 164,
          'Summary Rating' => 174
      }

      def initialize(state, schools, _)
        @state = state
        @schools = schools
        @rating_type = 'Summary Rating'
      end

      def default_url_options
        { trailing_slash: true, protocol: 'https', host: 'www.greatschools.org', port: nil }
      end

      def each_result(&block)
        results.each(&block)
      end

      def state_results
        state_data = JSON.parse(StateCache.for_state('ratings', @state)&.value)
        @rating_type = state_data['type']
        {}.tap do |hash|
          hash['id'] = test_type_to_id
          hash['year'] = state_data['year']
          hash['description'] = state_data['description']
        end
      end

      private

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
        @schools.map(&:id)
      end

      def ratings_hashes
        @_ratings_hashes ||= begin
          ratings_caches.map do |school|
            {
                id: school_uid(school.id),
                url: school_url(school),
                test_rating_id: test_type_to_id,
                rating: school_rating(school)
            }
          end
        end
      end

      def ratings_caches
        @_ratings_caches ||= begin
          query = SchoolCacheQuery.new.include_cache_keys('ratings').include_schools(@state, school_ids)
          query_results = query.query_and_use_cache_keys
          school_cache_results = SchoolCacheResults.new('ratings', query_results)
          school_cache_results.decorate_schools(schools)
        end
      end

      def school_uid(id)
        transpose_universal_id(@state, Struct.new(:id).new(id), ENTITY_TYPE_SCHOOL)
      end

      def state_uid
        transpose_universal_id(@state, nil, nil)
      end
    end
  end
end

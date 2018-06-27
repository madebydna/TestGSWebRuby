# frozen_string_literal: true

module Feeds
  module Subrating
    class DataReader
      include Rails.application.routes.url_helpers
      include UrlHelper

      attr_reader :state, :school_ids

      def initialize(state, school_ids = nil)
        @state = state
        @school_ids = school_ids || School.ids_by_state(@state)
      end

      def default_url_options
        { trailing_slash: true, protocol: 'https', host: 'www.greatschools.org', port: nil }
      end

      def each_result(&block)
        results.each(&block)
      end

      def state_results
        ratings_hashes.each_with_object({}) do |hash, state_results|
          unless hash[:ratings].empty?
            hash[:ratings].each do |rating_name, rating_obj|
              state_results[rating_name] ||= {}
              state_results[rating_name][:name] = rating_name
              state_results[rating_name][:description] = rating_obj.description
              state_results[rating_name][:year] = rating_obj.year
            end
          end
        end
      end

      private

      def results
        ratings_hashes
      end

      def schools
        @_schools ||= begin
          if @school_ids.present?
            School.on_db(state.downcase.to_sym).where(:id => school_ids).active
          else
            School.on_db(state.downcase.to_sym).all.active
          end
        end
      end

      def ratings_hashes
        @_ratings_hashed ||= begin
          ratings_caches.map do |school|
            {
                id: school.id,
                url: school_url(school),
                ratings: {}.tap do |hash|
                  hash['Test Scores'] = school.gsdata_test_scores_rating_hash if school.gsdata_test_scores_rating_hash
                  hash['Advanced Courses'] = school.courses_rating_hash if school.courses_rating_hash
                  hash['College Readiness'] = school.college_readiness_rating_hash if school.college_readiness_rating_hash
                  hash['Equity'] = school.equity_overview_rating_hash if school.equity_overview_rating_hash
                  hash['Academic Progress'] = school.academic_progress_rating_hash if school.academic_progress_rating_hash
                  hash['Student Growth'] = school.student_growth_rating_hash if school.student_growth_rating_hash
                  hash['Low Income'] = school.low_income_rating_hash if school.low_income_rating_hash
                end
            }
          end
        end
      end

      def ratings_caches
        @_ratings_caches ||= begin
          query = SchoolCacheQuery.new.include_cache_keys('ratings').include_schools(@state, @school_ids)
          query_results = query.query_and_use_cache_keys
          school_cache_results = SchoolCacheResults.new('ratings', query_results)
          school_cache_results.decorate_schools(schools)
        end
      end
    end
  end
end

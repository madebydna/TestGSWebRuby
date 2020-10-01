# frozen_string_literal: true

module Feeds
  module Subrating
    class DataReader
      include Rails.application.routes.url_helpers
      include UrlHelper

      attr_reader :state, :schools

      def initialize(state, schools, _)
        @state = state
        @schools = schools
      end

      def default_url_options
        { trailing_slash: true, protocol: 'https', host: 'www.greatschools.org', port: nil }
      end

      def each_result(&block)
        results.each(&block)
      end

      def state_results
        state_results = ratings_hashes.each_with_object({}) do |hash, results|
          unless hash[:ratings].empty?
            hash[:ratings].each do |rating_name, rating_obj|
              results[rating_name] ||= {}
              results[rating_name][:name] = rating_name
              results[rating_name][:description] = rating_obj.description
              results[rating_name][:year] = rating_obj.year
            end
          end
        end
        # For some reason, only the Discipline Flag has a description in the DB which is a
        # shared description for both flags
        if state_results['Attendance Flag'].present? && state_results['Discipline Flag'].present? &&
            state_results['Attendance Flag'][:description].blank?
          state_results['Attendance Flag'][:description] = state_results['Discipline Flag'][:description]
        end
        state_results
      end

      private

      def results
        ratings_hashes
      end

      def school_ids
        @schools.map(&:school_id)
      end

      def ratings_hashes
        @_ratings_hashed ||= begin
          ratings_caches.map do |school|
            {
                id: school.school_id,
                url: school_url(school),
                ratings: {}.tap do |hash|
                  hash['Test Scores'] = school.gsdata_test_scores_rating_hash if school.gsdata_test_scores_rating_hash
                  hash['College Readiness'] = school.college_readiness_rating_hash if school.college_readiness_rating_hash
                  hash['Equity'] = school.equity_overview_rating_hash if school.equity_overview_rating_hash
                  hash['Academic Progress'] = school.academic_progress_rating_hash if school.academic_progress_rating_hash
                  hash['Student Growth'] = school.student_growth_rating_hash if school.student_growth_rating_hash
                  hash['Discipline Flag'] = school.discipline_flag_hash if school.discipline_flag_hash
                  hash['Attendance Flag'] = school.absence_flag_hash if school.absence_flag_hash
                end
            }
          end
        end
      end

      def ratings_caches
        @_ratings_caches ||= begin
          query = SchoolRecordCacheQuery.new.include_cache_keys('ratings').include_schools(@state, school_ids)
          query_results = query.query_and_use_cache_keys
          school_cache_results = SchoolRecordCacheResults.new('ratings', query_results)
          school_cache_results.decorate_schools(schools)
        end
      end
    end
  end
end

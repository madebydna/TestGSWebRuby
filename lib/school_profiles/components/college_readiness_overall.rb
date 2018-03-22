# frozen_string_literal: trues

module SchoolProfiles
  module Components
    class CollegeReadinessOverall < Component
      def normalized_values
        school_cache_data_reader
          .decorated_school
          .ratings_by_type['College Readiness Rating']
          .having_most_recent_date
          .map { |h| normalize_rating_value(h) }
      end

      def normalize_rating_value(value)
        {
          breakdown: value.breakdowns,
          score: value.school_value,
          state_average: value.state_value,
          percentage: value_to_s(ethnicities_to_percentages[value.breakdowns.first])
        }
      end
    end
  end
end
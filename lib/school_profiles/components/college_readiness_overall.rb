# frozen_string_literal: trues

module SchoolProfiles
  module Components
    class CollegeReadinessOverall < Component
      def normalized_values
        cr_data = school_cache_data_reader.decorated_school.ratings_by_type['College Readiness Rating']
        cr_data ? cr_data.having_most_recent_date.map { |h| normalize_rating_value(h) } : []
      end

      def normalize_rating_value(value)
        {
          breakdown: value.breakdown,
          score: value.school_value,
          state_average: value.state_value,
          percentage: value_to_s(ethnicities_to_percentages[value.breakdown])
        }
      end
    end
  end
end
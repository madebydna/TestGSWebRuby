# frozen_string_literal: true

module Components
  module Ratings
    #Added a filter (not_having_academics) that is good for Advanced Coursework but may not work for all values in ratings cache
    class RatingsComponent < Component
      def normalized_values
        cache_data_reader
            .ratings_data(data_type).fetch(data_type, [])
            .map { |h| h.merge('breakdowns' => (h['breakdowns'] || 'All students').split(',')) }
            .map { |h| GsdataCaching::GsDataValue.from_hash(h) }
            .extend(GsdataCaching::GsDataValue::CollectionMethods)
            .having_one_breakdown
            .not_having_academics
            .having_most_recent_date
            .map { |h| normalize_rating_value(h) }
      end

      def normalize_rating_value(value)
        breakdown = (value.breakdowns - ['All students except 504 category']).first
        {
            breakdown: breakdown,
            score: value.school_value,
            state_average: value.state_value,
            percentage: value_to_s(ethnicities_to_percentages[breakdown])
        }
      end
    end
  end
end

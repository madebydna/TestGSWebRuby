# frozen_string_literal: true

module Components
  module Metrics
    class MetricsComponent < Component
      attr_accessor :lower_range, :upper_range

      def normalized_values
        @normalized_values ||=
          cache_data_reader.decorated_metrics_data(data_type)
                           .having_most_recent_date
                           .no_subject_or_all_subjects
                           .having_all_students_or_breakdown_in(valid_breakdowns)
                           .map { |h| cache_hash_to_standard_hash(h) }
      end

      def cache_hash_to_standard_hash(hash)
        breakdown = hash['breakdown']
        {
          breakdown: breakdown,
          score: hash['school_value'],
          grade: hash['grade'],
          state_average: hash['state_average'],
          percentage: breakdown_percentage(hash),
          year: hash['year'] || ((hash['source_date_valid'] || '')[0..3]).presence || hash['source_year']
        }
      end

      def standard_hash_to_value_hash(h)
        {
          breakdown: t(h[:breakdown]),
          label: text_value(h[:score]),
          score: h[:score],
          lower_range: lower_range,
          upper_range: upper_range,
          state_average: h[:state_average],
          state_average_label: value_to_s(h[:state_average]),
          display_percentages: true,
          percentage: value_to_s(h[:percentage]),
          visualization: 'bar_custom_range',
        }
      end

      def breakdown_percentage(value)
        value_to_s(ethnicities_to_percentages[value.breakdown])
      end
    end
  end
end
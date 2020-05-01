# frozen_string_literal: true

module Components
  module GraduationRates
    class GraduationRateComponent < Component

      def normalized_values
        cache_data_reader
        .metrics_data(data_type)
        .values
        .flatten
        .map { |h| cache_hash_to_standard_hash(h) }
      end

      # TODO: move somewhere more sensible, where it can be reused
      def cache_hash_to_standard_hash(hash)
        breakdown = hash['original_breakdown'] || hash['breakdown']
        breakdown = 'All students' if breakdown == 'All'
        {
          breakdown: breakdown,
          score: hash['school_value'],
          state_average: hash['state_average'],
          percentage: breakdown_percentage(breakdown)
        }
      end

      def breakdown_percentage(breakdown)
        value_to_s(ethnicities_to_percentages[breakdown])
      end
    end
  end
end

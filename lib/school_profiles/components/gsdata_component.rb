module SchoolProfiles
  module Components
    class GsdataComponent < Component
      def normalized_values
        school_cache_data_reader
          .gsdata_data(data_type).fetch(data_type, [])
          .map { |h| h.merge('breakdowns' => (h['breakdowns'] || 'All students').split(',')) }
          .select { |h| h['breakdowns'].size < 2 }
          .map { |h| normalize_test_scores_hash(h) }
      end

      def normalize_test_scores_hash(hash)
        breakdown = (hash['breakdowns'] - ['All students except 504 category']).first
        {
          breakdown: breakdown,
          score: hash['school_value'],
          state_average: hash['state_value'],
          percentage: value_to_s(ethnicities_to_percentages[breakdown])
        }
      end
    end
  end
end

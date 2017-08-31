module SchoolProfiles
  module Components
    class GsdataComponent < Component
      def normalized_values
        school_cache_data_reader
          .gsdata_data(data_type).fetch(data_type, [])
          .map { |h| h.merge('breakdowns' => (h['breakdowns'] || 'All students').split(',')) }
          .map { |h| GsdataCaching::GsDataValue.from_hash(h) }
          .extend(GsdataCaching::GsDataValue::CollectionMethods)
          .having_one_breakdown
          .having_most_recent_date
          .map { |h| normalize_gsdata_value(h) }
      end

      def normalize_gsdata_value(value)
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

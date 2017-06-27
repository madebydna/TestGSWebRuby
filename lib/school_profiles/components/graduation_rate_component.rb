module SchoolProfiles
  module Components
    class GraduationRateComponent < Component
      def narration
        I18n.t('RE Grad rates narration', scope: 'lib.equity_gsdata', subject: t(data_type)) # TODO: update scope after moving translations
      end

      def normalized_values
        school_cache_data_reader
        .characteristics_data(data_type)
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
module SchoolProfiles
  module Components
    class TestScoresComponent < Component
      def narration
        t('RE Test scores narration', scope: 'lib.equity_gsdata', subject: t(data_type)) # TODO: update scope after moving translations
      end

      def normalized_values
        @_normalized_values ||= (
          school_cache_data_reader
            .flat_test_scores_for_latest_year
            .select { |h| h[:subject] == data_type } # TODO: using data type variable to hold subject. Improve
            .map { |h| normalize_test_scores_hash(h) }
        )
      end

      def valid_breakdowns
        @valid_breakdowns || ethnicities_to_percentages.keys
      end

      def normalize_test_scores_hash(hash)
        breakdown = hash[:breakdown]
        normalized_breakdown = breakdown == 'All' ? 'All students' : breakdown
        hash.merge(
          breakdown: normalized_breakdown,
          percentage: value_to_s(ethnicities_to_percentages[normalized_breakdown])
        )
      end
    end
  end
end

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
            .map { |h| cache_hash_to_standard_hash(h) }
        )
      end

      def values
        @_values ||= (
          values_by_test_label = normalized_values
            .select(&method(:filter_predicate))
            .sort(&method(:comparator))
            .group_by { |h| h[:test_label] }

          values_by_test_label.keep_if do |test_label, values|
            array_contains_any_valid_data?(values)
          end
          values_by_test_label.values.flatten.each do |h|
            h.replace(standard_hash_to_value_hash(h))
          end
          values_by_test_label
        )
      end
      
      def cache_hash_to_standard_hash(hash)
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

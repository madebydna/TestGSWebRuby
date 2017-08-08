module SchoolProfiles
  module Components
    class TestScoresRatingsComponent < Component

      def narration
        t('RE Test scores overview narration', scope: 'lib.equity_gsdata', subject: t(data_type)) # TODO: update scope after moving translations
      end

      def normalized_values
        @_normalized_values ||= (
          school_cache_data_reader.test_scores_all_rating_hash
              .map { |h| cache_hash_to_standard_hash(h) }
        )
      end

      def values
        @_values ||= (
          normalized_values.select {|h| rating_has_valid_data?(h)}
                         .map { |h| standard_hash_to_value_hash_ratings(h) }
                         .sort(&method(:comparator))
        )
      end

      def cache_hash_to_standard_hash(hash)
        hash['percentage'] =  breakdown_percentage(hash['breakdown'])
        hash
      end
      #
      def breakdown_percentage(breakdown)
        value_to_s(ethnicities_to_percentages[breakdown])
      end
    end
  end
end

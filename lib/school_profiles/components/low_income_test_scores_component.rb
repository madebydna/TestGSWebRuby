module SchoolProfiles
  module Components
    class LowIncomeTestScoresComponent < TestScoresComponent
      def narration
        low_income_hash = normalized_values.find { |h| h[:breakdown] == 'Economically disadvantaged' } || {}
        all_hash = normalized_values.find { |h| h[:breakdown] == 'All students' } || {}

        yml_key = NarrativeLowIncomeTestScores.new(school_cache_data_reader: school_cache_data_reader).yml_key(
          low_income_hash[:score],
          low_income_hash[:state_average],
          all_hash[:state_average]
        )

        t(yml_key + '_html', scope: 'lib.test_scores.narrative.low_income', subject: t(data_type))
      end
    end
  end
end

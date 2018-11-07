# frozen_string_literal: true

module Components
  module TestScores
    class LowIncomeTestScoresComponent < TestScoresComponent
      def narration
        low_income_hash = normalized_values.values.flatten.find { |h| h[:breakdown] == 'Low-income' } || {}
        all_hash = normalized_values.values.flatten.find { |h| h[:breakdown] == 'All students' } || {}

        yml_key = SchoolProfiles::NarrativeLowIncomeTestScores.yml_key(
          low_income_hash[:score],
          low_income_hash[:state_average],
          all_hash[:state_average]
        )

        t(yml_key + '_html', scope: 'lib.test_scores.narrative.low_income', subject: t(data_type))
      end

      # Keep "All" or "All students" on top
      # Then "Economically disadvantaged"
      # Finally "Not economically disadvantaged"
      #
      # Keep in mind breakdown string must not be translated yet
      def comparator(h1, h2)
        return -2 if h1[:breakdown] == 'All students'
        return 2 if h2[:breakdown] == 'All students'
        return -1 if h1[:breakdown] == 'Economically disadvantaged'
        return 1 if h2[:breakdown] == 'Economically disadvantaged'
        return h2[:percentage].to_f <=> h1[:percentage].to_f
      end

      def ethnicities_to_percentages
        low_income_to_percentages
      end
    end
  end
end

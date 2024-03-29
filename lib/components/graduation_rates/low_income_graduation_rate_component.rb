# frozen_string_literal: true

module Components
  module GraduationRates
    class LowIncomeGraduationRateComponent < GraduationRateComponent
      def narration
        low_income_hash = normalized_values.find { |h| h[:breakdown] == 'Economically disadvantaged' } || {}
        all_hash = normalized_values.find { |h| h[:breakdown] == 'All students' } || {}

        if low_income_hash[:state_average].present? && low_income_hash[:score] && all_hash[:state_average]
          yml_key = SchoolProfiles::NarrationFormula.new
            .low_income_grad_rate_and_entrance_requirements(
              low_income_hash[:state_average],
              low_income_hash[:score],
              all_hash[:state_average]
            )
        end
        yml_key ||= '0'

        t(yml_key + '_html', scope: 'lib.test_scores.narrative.' + data_type)
      end

      def breakdown_percentage(breakdown)
        value_to_s(low_income_to_percentages[breakdown])
      end
    end
  end
end

# frozen_string_literal: true

module Components
  module GraduationRates
    class LowIncomeGraduationRateComponent < GraduationRateComponent
      def narration
        low_income_hash = normalized_values.find { |h| h[:breakdown] == 'Economically disadvantaged' } || {}
        all_hash = normalized_values.find { |h| h[:breakdown] == 'All students' } || all_students_from_state_cache

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

      # This is needed in the rare case that the school does not have an "All students"
      # breakdown for the data type "4-year high school graduation rate"
      # See https://jira.greatschools.org/browse/JT-10347
      def all_students_from_state_cache
        state_cache_data_reader = StateCacheDataReader.new(cache_data_reader.school_state.downcase, state_cache_keys: ['metrics'])
        all_students = state_cache_data_reader.decorated_metrics_data(data_type).for_all_students.try(:first)
        all_students.present? ? { state_average: all_students.state_value } : {}
      end
    end
  end
end

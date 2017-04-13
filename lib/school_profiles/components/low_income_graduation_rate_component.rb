module SchoolProfiles
  module Components
    class LowIncomeGraduationRateComponent < GraduationRateComponent
      def narration
        low_income_hash = normalized_values.find { |h| h[:breakdown] == 'Economically disadvantaged' } || {}
        all_hash = normalized_values.find { |h| h[:breakdown] == 'All students' } || {}

        yml_key = NarrativeLowIncomeGradRateAndEntranceReq.new(
          school_cache_data_reader: school_cache_data_reader
        ).get_narration_calculation(
          data_type,
          low_income_hash[:score],
          all_hash[:state_average]
        )
        yml_key ||= '0'

        t(yml_key + '_html', scope: 'lib.test_scores.narrative.' + data_type)
      end
    end
  end
end

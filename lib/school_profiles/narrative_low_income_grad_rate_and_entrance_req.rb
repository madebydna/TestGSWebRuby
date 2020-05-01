module SchoolProfiles
  class NarrativeLowIncomeGradRateAndEntranceReq

    attr_accessor :metrics
    def initialize(metrics)
      @metrics = metrics
    end

    def auto_narrative_calculate_and_add
      metrics_low_income_narrative('4-year high school graduation rate')
      metrics_low_income_narrative('Percent of students who meet UC/CSU entrance requirements')
    end

    def metrics_low_income_narrative(data_type_name)
      if metrics.present? && metrics[data_type_name].present?
        li_hash = metrics[data_type_name].find { |d| d['breakdown'] == 'Economically disadvantaged' }
        all_hash = metrics[data_type_name].find { |d| d['breakdown'] == 'All students' }
        if li_hash.present?
          key_value = narration_calculation(li_hash, all_hash)
          key_value = '0' if key_value.blank?
          li_hash['narrative'] = low_income_narration(key_value, data_type_name)
        end
      end
    end

    def low_income_narration(key, subject)
      full_key = 'lib.test_scores.narrative.' << subject << '.' << key << '_html'
      I18n.t(full_key)
    end

    def narration_calculation(li_hash, all_hash)
      get_narration_calculation(
        li_hash['school_value'],
        li_hash['state_average'],
        all_hash['state_average']
      )
    end

    def get_narration_calculation(school_value, state_average, all_state_average)
      if school_value.present? && state_average.present? && all_state_average.present?
        nf = SchoolProfiles::NarrationFormula.new
        return nf.low_income_grad_rate_and_entrance_requirements(state_average, school_value, all_state_average)
      else
        return '0'
      end
    end
  end
end

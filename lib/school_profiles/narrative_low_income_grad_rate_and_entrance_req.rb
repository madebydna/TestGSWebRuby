module SchoolProfiles
  class NarrativeLowIncomeGradRateAndEntranceReq
    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader
    end

    def characteristics
      @school_cache_data_reader.characteristics
    end

    def auto_narrative_calculate_and_add
      characteristics_low_income_narrative('4-year high school graduation rate')
      characteristics_low_income_narrative('Percent of students who meet UC/CSU entrance requirements')
    end

    def characteristics_low_income_narrative(data_type_name)
      if characteristics.present? && characteristics[data_type_name].present?
        data = characteristics[data_type_name].find do |data| data['breakdown'] == 'Economically disadvantaged' end
        key_value = narration_calculation data_type_name, data
        data['narrative'] = low_income_narration key_value, data_type_name
      end
    end

    def low_income_narration(key, subject)
      full_key = 'lib.test_scores.narrative.' << subject << '.' << key << '_html'
      I18n.t(full_key)
    end

    def narration_calculation(data_type_name, data)
      sch_avg = data['school_value']
      st_avg = data['state_average']
      st_moe = 1
      nf = SchoolProfiles::NarrationFormula.new
      if data_type_name == 'Percent of students who meet UC/CSU entrance requirements' && sch_avg.present? && st_avg.present?
        very_low = 20
        nf.low_income_grad_rate_and_entrance_requirements sch_avg, st_avg, st_moe, very_low
      elsif data_type_name == '4-year high school graduation rate' && sch_avg.present? && st_avg.present?
        very_low = 10
        nf.low_income_grad_rate_and_entrance_requirements sch_avg, st_avg, st_moe, very_low
      end
    end
  end
end
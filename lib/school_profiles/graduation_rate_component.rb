module SchoolProfiles
  class GraduationRateComponent < ::SchoolProfiles::Component
    def narration
      SchoolProfiles::NarrativeLowIncomeGradRateAndEntranceReq
      .new(school_cache_data_reader: school_cache_data_reader)
      .get_characteristics_low_income_narrative(data_type)
    end

    def normalized_values
      school_cache_data_reader
      .characteristics_data(data_type)
      .values
      .flatten
      .map { |h| normalize_characteristics_hash(h) }
    end

    # TODO: move somewhere more sensible, where it can be reused
    def normalize_characteristics_hash(hash)
      breakdown = hash['original_breakdown'] || hash['breakdown']
      breakdown = 'All students' if breakdown == 'All'
      {
        breakdown: breakdown,
        score: hash['school_value'],
        state_average: hash['state_average'],
        percentage: value_to_s(ethnicities_to_percentages[breakdown])
      }
    end

    def ethnicities_to_percentages
      SchoolProfiles::EthnicityPercentages.new(
        school_cache_data_reader: school_cache_data_reader
      ).ethnicities_to_percentages
    end
  end
end

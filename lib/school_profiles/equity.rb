module SchoolProfiles
  class Equity
    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader
      @data_type_id = '236'
    end

    def test_scores_by_ethnicity
      @school_cache_data_reader.test_scores[@data_type_id]
    end

    def enrollment
      enrollment_string = @school_cache_data_reader.students_enrolled
      return enrollment_string.gsub(',','').to_i if enrollment_string
    end

    def characteristics
      @school_cache_data_reader.characteristics.slice(
        '4-year high school graduation rate',
        'Percent of students who meet UC/CSU entrance requirements'
      )
    end

    def rating_low_income
      @school_cache_data_reader.equity_ratings_breakdown('Economically disadvantaged')
    end

    def ethnicity_visible?
      !test_scores_by_ethnicity.blank?
    end

    def low_income_visible?
      if test_scores_by_ethnicity.blank?
        false
      else
        test_scores_by_ethnicity.has_key?('Economically disadvantaged')
      end
    end
  end
end

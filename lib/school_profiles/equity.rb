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

    def graduation_rate_data
      @school_cache_data_reader.graduation_rate_data
    end
  end
end

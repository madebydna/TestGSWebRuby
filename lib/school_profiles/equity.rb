module SchoolProfiles
  class Equity
    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader
      @data_type_id = '236'
    end

    def test_scores_by_ethnicity
      @school_cache_data_reader.test_scores[@data_type_id]
    end
  end
end

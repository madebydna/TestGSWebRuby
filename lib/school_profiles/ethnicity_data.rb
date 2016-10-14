module SchoolProfiles
  class EthnicityData

    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader
    end

    def data_values
      @school_cache_data_reader.ethnicity_data
    end
  end
end

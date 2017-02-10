module SchoolProfiles
  class Students

    OTHER_BREAKDOWN_KEYS = [
      "English learners",
      "Students participating in free or reduced-price lunch program",
    ].freeze

    GENDER_KEYS = [
      "Male",
      "Female"
    ].freeze

    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader
    end

    def ethnicity_data
      @school_cache_data_reader.ethnicity_data.select { |e| e.has_key?('school_value') }
    end

    def gender_data
      @school_cache_data_reader.characteristics_data(*GENDER_KEYS)
    end

    def subgroups_data
      @school_cache_data_reader.characteristics_data(*OTHER_BREAKDOWN_KEYS)
    end

    def visible?
      ethnicity_data.present? || gender_data.present? || subgroups_data.present?
    end
  end
end

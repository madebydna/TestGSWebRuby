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

    def ethnicity_data_source
      ethnicity_data.each_with_object({}) do |ethnicity_hash, output|
        output[ethnicity_hash['breakdown']] = {
            source: I18n.db_t(ethnicity_hash['source']),
            year: ethnicity_hash['year']
        }
      end
    end

    def gender_data
      @school_cache_data_reader.characteristics_data(*GENDER_KEYS)
    end

    def gender_data_source
      gender_data.each_with_object({}) do |(breakdown, data_array), output|
        data_array.each do |data_hash|
          output[breakdown] = {
              source: data_hash['source'],
              year: data_hash['year']
          }
        end
      end
    end

    def subgroups_data
      @school_cache_data_reader.characteristics_data(*OTHER_BREAKDOWN_KEYS)
    end

    def subgroups_data_source
      subgroups_data.each_with_object({}) do |(breakdown, data_array), output|
        data_array.each do |data_hash|
          output[breakdown] = {
              source: data_hash['source'],
              year: data_hash['year']
          }
        end
      end
    end

    def visible?
      ethnicity_data.present? || gender_data.present? || subgroups_data.present?
    end
  end
end

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
        output['ethnicity'] = {
            source: I18n.db_t(ethnicity_hash['source']),
            year: ethnicity_hash['year']
        }
      end
    end

    def sources_for_view
      str = '<h1 style="text-align:center; font-size:22px; font-family:RobotoSlab-Bold;">GreatSchools profile data sources &amp; information</h1>'
      str << '<div style="padding:40px 0 40px 20px;">'
      str << '<h4 style="font-family:RobotoSlab-Bold;">Ethnicity</h4>'
      str << "<div style='padding-bottom:40px;'><span>Source: #{ethnicity_data_source['ethnicity'][:source]}, "
      str << "#{ethnicity_data_source['ethnicity'][:year]}</span></div>"
      str << '<h4 style="font-family:RobotoSlab-Bold;">Gender</h4>'
      str << "<div style='padding-bottom:40px;'><span>Source: #{gender_data_source['gender'][:source]}, "
      str << "#{gender_data_source['gender'][:year]}</span></div>"
      str << '<h4 style="font-family:RobotoSlab-Bold;">Subgroups</h4>'
      str << "<div><span>Source: #{subgroups_data_source['subgroups'][:source]}, "
      str << "#{subgroups_data_source['subgroups'][:year]}</span></div>"
      str << '</div>'
    end

    def gender_data
      @school_cache_data_reader.characteristics_data(*GENDER_KEYS)
    end

    def gender_data_source
      gender_data.each_with_object({}) do |(gender, array_of_one_hash), output|
        array_of_one_hash.each do |hash|
          output['gender'] = {
              source: hash['source'],
              year: hash['year']
          }
        end
      end
    end

    def subgroups_data
      @school_cache_data_reader.characteristics_data(*OTHER_BREAKDOWN_KEYS)
    end

    def subgroups_data_source
      subgroups_data.each_with_object({}) do |(subgroup, array_of_one_hash), output|
        array_of_one_hash.each do |hash|
          output['subgroups'] = {
              source: hash['source'],
              year: hash['year']
          }
        end
      end
    end

    def visible?
      ethnicity_data.present? || gender_data.present? || subgroups_data.present?
    end
  end
end

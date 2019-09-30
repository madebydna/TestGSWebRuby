module SchoolProfiles
  class EquityGsdata
    COURSES_DATA_TYPES = {
        'Percentage AP enrolled grades 9-12' => {type: :person},
        'Percentage of students enrolled in Dual Enrollment classes grade 9-12' => {type: :person},
        'Percentage of students enrolled in IB grades 9-12' => {type: :person},
        'Number of Advanced Courses Taken per Student' => {type: :plain, precision: 1}
    }

    DISCIPLINE_DATA_TYPES = {
        'Percentage of students suspended out of school' => {type: :person_reversed},
        'Percentage of students chronically absent (15+ days)' => {type: :person_reversed}
    }

    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader
    end

    def sources
      generate_hash(COURSES_DATA_TYPES)
        .merge(generate_hash(DISCIPLINE_DATA_TYPES))
        .merge(students_with_disabilities_hash)
    end

    private

    # Students with IDEA catagory disabilities
    def students_with_disabilities_hash
      @school_cache_data_reader
        .decorated_gsdata_datas(*DISCIPLINE_DATA_TYPES.keys)
        .each_with_object({}) do |(data_type_name, array_of_gsdata_values), hash|
          hash.merge!(
            sources_hash(
              data_type_name,
              array_of_gsdata_values.recent_students_with_disabilities_school_values
            )
          )
        end
    end

    def generate_hash(data_types)
      @school_cache_data_reader
        .decorated_gsdata_datas(*data_types.keys)
        .each_with_object({}) do |(data_type_name, array_of_gsdata_values), hash|
          hash.merge!(
            sources_hash(
              data_type_name,
              array_of_gsdata_values.recent_ethnicity_school_values
            )
          )
      end
    end

    def subject_name(data_type_name)
      I18n.t(data_type_name, scope: 'lib.equity_gsdata', default: data_type_name)
    end

    def sources_hash(data_type_name, value_hashes)
      return {} if value_hashes.blank?
      {
        subject_name(data_type_name) => {
          info_text: I18n.t(data_type_name, scope: 'lib.equity_gsdata.data_point_info_texts', default: ''),
          sources: value_hashes.map { |dv| {name: dv.source_name, year: dv.source_year }}.uniq
        }
      }
    end
  end
end

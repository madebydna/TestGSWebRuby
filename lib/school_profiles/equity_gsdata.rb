module SchoolProfiles
  class EquityGsdata
    # TODO: This class used to be a data/display class. Now it only serves up sources, and the data was migrated to the
    #       ComponentGroup architecture. Need to migrate these sources over there so the sources logic is consistent
    #       with display.
    DISCIPLINE_DATA_TYPES = {
        'Percentage of students suspended out of school' => {type: :person_reversed},
        'Percentage of students chronically absent (15+ days)' => {type: :person_reversed}
    }

    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader
    end

    def sources
      generate_hash(DISCIPLINE_DATA_TYPES)
        .merge(students_with_disabilities_hash)
    end

    private

    # Students with IDEA catagory disabilities
    def students_with_disabilities_hash
      @school_cache_data_reader
        .decorated_metrics_datas(*DISCIPLINE_DATA_TYPES.keys)
        .each_with_object({}) do |(data_type_name, array_of_metrics_values), hash|
          hash.merge!(
            sources_hash(
              data_type_name,
              array_of_metrics_values.recent_students_with_disabilities_school_values
            )
          )
        end
    end

    def generate_hash(data_types)
      @school_cache_data_reader
        .decorated_metrics_datas(*data_types.keys)
        .each_with_object({}) do |(data_type_name, array_of_metrics_values), hash|
          hash.merge!(
            sources_hash(
              data_type_name,
              array_of_metrics_values.recent_ethnicity_school_values
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
          sources: value_hashes.map { |dv| {name: dv.source, year: dv.source_year }}.uniq
        }
      }
    end
  end
end

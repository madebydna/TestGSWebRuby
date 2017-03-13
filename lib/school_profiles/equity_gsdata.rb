module SchoolProfiles
  class EquityGsdata
    attr_reader :sources

    BREAKDOWN_ALL = 'All'
    SUBJECT_ALL_PERCENTAGE = 200 # This is also used in react to determine different layout in ethnicity for All students
    COURSES_DATA_TYPES = {
        'Percentage AP enrolled grades 9-12' => {type: :bar},
        'Number of Advanced Courses Taken per Student' => {type: :plain, precision: 2}
    }

    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader
      @sources = {}
    end

    def equity_gsdata_hash
      @_equity_gsdata_hash ||= ({
          I18n.t('courses_title', scope: 'lib.equity_gsdata') => courses_hash
      })
    end

    private

    def courses_hash
      data = @school_cache_data_reader.gsdata_data(*COURSES_DATA_TYPES.keys)
      data.each_with_object({}) do |(data_type_name, array_of_hashes), output_hash|
        max_year = array_of_hashes.map { |hash| hash['source_year'].to_i }.max
        matching_breakdowns = array_of_hashes.select(&matching_values(max_year))
        unless matching_breakdowns.empty?
          output_hash.merge!(subject_hash(data_type_name, matching_breakdowns))

          @sources.merge!(sources_hash(data_type_name, matching_breakdowns))
        end
      end
    end

    def subject_name(data_type_name)
      I18n.t(data_type_name, scope: 'lib.equity_gsdata', default: data_type_name)
    end

    def subject_hash(data_type_name, value_hashes)
      type = COURSES_DATA_TYPES[data_type_name][:type]
      precision = COURSES_DATA_TYPES[data_type_name][:precision] || 0
      {
          subject_name(data_type_name) => {
              narration: I18n.t(data_type_name, scope: 'lib.equity_gsdata.data_point_info_texts', default: ''),
              values: value_hashes.map(&hash_for_display(precision)).sort_by(&percentage_desc),
              type: type
          }
      }
    end

    def sources_hash(data_type_name, value_hashes)
      {
          subject_name(data_type_name) => {
              info_text: I18n.t(data_type_name, scope: 'lib.equity_gsdata.data_point_info_texts', default: ''),
              sources: value_hashes.map { |hash| {name: hash['source_name'], year: hash['source_year'] }}.uniq
          }
      }
    end

    def matching_values(max_year)
      lambda do |hash|
        hash.has_key?('school_value') &&
            hash['source_year'].to_i == max_year &&
            (hash['breakdowns'].blank? || ethnicity_breakdowns.keys.include?(hash['breakdowns']))
      end
    end

    def hash_for_display(precision = 0)
      lambda do |hash|
        breakdown = hash['breakdowns'] || BREAKDOWN_ALL
        breakdown_name_str = I18n.t(breakdown, scope: 'lib.equity_gsdata', default: breakdown)
        {
            breakdown: breakdown_name_str,
            score: value_to_s(hash['school_value'], precision),
            state_average: value_to_s(hash['state_value'], precision),
            percentage: value_to_s(ethnicity_breakdowns[breakdown], 0),
            display_percentages: true,
        }.compact
      end
    end

    def value_to_s(value, precision=0)
      return nil if value.nil?
      num = value.to_f.round(precision)
      if precision == 0 && num < 1
        '<1'
      else
        num.to_s
      end
    end

    def percentage_desc
      ->(hash) { -(hash[:percentage].to_f) }
    end

    def ethnicity_breakdowns
      @_ethnicity_breakdowns = begin
        ethnicity_breakdown = {BREAKDOWN_ALL=>SUBJECT_ALL_PERCENTAGE}
        @school_cache_data_reader.ethnicity_data.each do | ed |
          ethnicity_breakdown[ed['breakdown']] = ed['school_value']
          ethnicity_breakdown[ed['original_breakdown']] = ed['school_value']
        end
        ethnicity_breakdown.compact
      end
    end
  end
end
module SchoolProfiles
  class EquityGsdata
    attr_reader :sources

    BREAKDOWN_ALL = 'All'
    SUBJECT_ALL_PERCENTAGE = 200 # This is also used in react to determine different layout in ethnicity for All students
    COURSES_DATA_TYPES = ['Percentage AP enrolled grades 9-12'] #, 'Number of Advanced Courses Taken per Student']

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
      data = @school_cache_data_reader.gsdata_data(*COURSES_DATA_TYPES)
      max_year = data.reduce(0, &max_year_across_keys)
      data.each_with_object({}) do |(data_type_name, array_of_hashes), output_hash|
        has_values = array_of_hashes.select(&has_school_value)
        matching_years = has_values.select(&matching_source_year(max_year))
        matching_breakdowns = matching_years.select(&breakdowns_blank_or_includes(ethnicity_breakdowns.keys))
        unless matching_breakdowns.empty?
          display_hashes = matching_breakdowns.map(&hash_for_display)
          subject_name = I18n.t(data_type_name, scope: 'lib.equity_gsdata', default: data_type_name)
          output_hash[subject_name] = {
              narration: I18n.t(data_type_name, scope: 'lib.equity_gsdata.data_point_info_texts', default: ''),
              values: display_hashes.sort_by(&percentage_desc)
          }
          # note sources
          @sources[subject_name] = {
              info_text: I18n.t(data_type_name, scope: 'lib.equity_gsdata.data_point_info_texts', default: ''),
              sources: matching_breakdowns.map { |hash| {name: hash['source_name'], year: hash['source_year'] }}.uniq
          }
        end
      end
    end

    def max_year_across_keys
      lambda do |max, (_, array_of_hashes)|
        local_max = array_of_hashes.map { |hash| hash['source_year'].to_i }.max
        max > local_max ? max : local_max
      end
    end

    def hash_for_display
      lambda do |hash|
        breakdown = hash['breakdowns'] || BREAKDOWN_ALL
        breakdown_name_str = I18n.t(breakdown, scope: 'lib.equity_gsdata', default: breakdown)
        {
            breakdown: breakdown_name_str,
            year: hash['source_year'],
            score: hash['school_value'],
            state_average: hash['state_value'],
            percentage: ethnicity_breakdowns[breakdown].to_f,
            display_percentages: true,
        }.compact
      end
    end

    def percentage_desc
      ->(hash) { -hash[:percentage] }
    end

    def has_school_value
      ->(hash) { hash.has_key?('school_value') }
    end

    def matching_source_year(year)
      ->(hash) { hash['source_year'].to_i == year }
    end

    def breakdowns_blank_or_includes(valid_breakdowns)
      ->(hash) { hash['breakdowns'].blank? || valid_breakdowns.include?(hash['breakdowns']) }
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
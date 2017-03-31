module SchoolProfiles
  class EquityGsdata
    attr_reader :sources

    BREAKDOWN_ALL = 'All'
    SUBJECT_ALL_PERCENTAGE = 200 # This is also used in react to determine different layout in ethnicity for All students
    STUDENTS_WITH_DISABILITIES = 'Students with disabilities'
    STUDENTS_WITH_IDEA_CATEGORY_DISABILITIES = 'Students with IDEA catagory disabilities'
    COURSES = 1
    DISCIPLINE = 2
    DISABILITIES = 3

    NATIVE_AMERICAN = [
        'American Indian/Alaska Native',
        'Native American'
    ]

    PACIFIC_ISLANDER = [
        'Pacific Islander',
        'Hawaiian Native/Pacific Islander',
        'Native Hawaiian or Other Pacific Islander'
    ]

    COURSES_DATA_TYPES = {
        'Percentage AP enrolled grades 9-12' => {type: :person},
        'Number of Advanced Courses Taken per Student' => {type: :plain, precision: 1}
    }

    DISCIPLINE_DATA_TYPES = {
        'Percentage of students suspended out of school' => {type: :person_reversed},
        'Percentage of students chronically absent (15+ days)' => {type: :person_reversed}
    }
    DISABILITIES_BREAKDOWN = {
        'Students with disabilities' => {type: :person}
    }

    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader
      @sources = {}
    end

    def equity_gsdata_courses_hash
      @_equity_gsdata_courses_hash ||= ({
          I18n.t('courses_title', scope: 'lib.equity_gsdata') => courses_hash
      })
    end

    def equity_gsdata_discipline_hash
      @_equity_gsdata_discipline_hash ||= ({
          I18n.t('discipline_title', scope: 'lib.equity_gsdata') => discipline_hash

      })
    end

    def equity_gsdata_disabilities_hash
      @_equity_gsdata_disabilities_hash ||= ({
          I18n.t('discipline_title', scope: 'lib.equity_gsdata') => students_with_disabilities_hash

      })
    end

    def sources
      equity_gsdata_courses_hash # Need to build the data hash to compute the sources
      equity_gsdata_discipline_hash
      equity_gsdata_disabilities_hash
      @sources
    end

    private

    # Students with IDEA catagory disabilities

    def students_with_disabilities_hash
      data = @school_cache_data_reader.gsdata_data(*DISCIPLINE_DATA_TYPES.keys)
      data.each_with_object({}) do |(data_type_name, array_of_hashes), output_hash|
        max_year = array_of_hashes.map { |hash| hash['source_year'].to_i }.max
        matching_breakdowns = array_of_hashes.select(&matching_students_with_disabilities_values(max_year))
        if matching_breakdowns.present? && !(matching_breakdowns.length == 1 && !matching_breakdowns.first.has_key?('breakdowns'))
          sh = subject_hash(DISCIPLINE_DATA_TYPES, data_type_name, matching_breakdowns, DISABILITIES)
          output_hash.merge!(sh)

          @sources.merge!(sources_hash(data_type_name, matching_breakdowns))
        end
      end
    end

    def discipline_hash
      generate_hash DISCIPLINE_DATA_TYPES, DISCIPLINE
    end

    def courses_hash
      generate_hash COURSES_DATA_TYPES, COURSES
    end

    def generate_hash(data_types, hash_type)
      data = @school_cache_data_reader.gsdata_data(*data_types.keys)
      data.each_with_object({}) do |(data_type_name, array_of_hashes), output_hash|
        max_year = array_of_hashes.map { |hash| hash['source_year'].to_i }.max
        matching_breakdowns = array_of_hashes.select(&matching_values(max_year))
        unless matching_breakdowns.empty?
          output_hash.merge!(subject_hash(data_types, data_type_name, matching_breakdowns, hash_type))

          @sources.merge!(sources_hash(data_type_name, matching_breakdowns))
        end
      end
    end

    def subject_name(data_type_name)
      I18n.t(data_type_name, scope: 'lib.equity_gsdata', default: data_type_name)
    end

    def subject_hash(data_types, data_type_name, value_hashes, hash_type)
      type = data_types[data_type_name][:type]
      precision = data_types[data_type_name][:precision] || 0
      {
          subject_name(data_type_name) => {
              narration: narration_text(data_types, data_type_name, hash_type),
              values: value_hashes.map(&hash_for_display(precision)).sort_by(&percentage_desc),
              type: type
          }
      }
    end

    def narration_text(data_types, data_type_name, hash_type)
      case hash_type
        when COURSES
          I18n.t(data_type_name, scope: 'lib.equity_gsdata.data_point_info_texts', default: '')
        when DISCIPLINE
          I18n.t(data_type_name, scope: 'lib.equity_gsdata.narration.ER', default: '')
        when DISABILITIES
          I18n.t(data_type_name, scope: 'lib.equity_gsdata.narration.SD', default: '')
      end

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
            (hash['breakdowns'].blank? ||
                ethnicity_breakdowns.keys.include?(suspension_breakdown_matching(hash['breakdowns']))
            )
      end
    end

    def matching_students_with_disabilities_values(max_year)
      lambda do |hash|
        hash.has_key?('school_value') &&
            hash['source_year'].to_i == max_year &&
              ((hash['breakdowns'] == STUDENTS_WITH_DISABILITIES || !hash.has_key?('breakdowns')) ||
                  (hash['breakdowns'] == STUDENTS_WITH_IDEA_CATEGORY_DISABILITIES || !hash.has_key?('breakdowns')))
      end
    end

    # hack for gsdata Percentage of students suspended out of school
    def suspension_breakdown_matching(breakdowns)
      breakdowns.gsub('All students except 504 category,','')
    end

    def hash_for_display(precision = 0)
      lambda do |hash|
        breakdown = hash['breakdowns'] || BREAKDOWN_ALL
        # hack for gsdata Percentage of students suspended out of school
        breakdown.gsub!('All students except 504 category,','')
        breakdown_name_str = I18n.t(breakdown, scope: 'lib.equity_gsdata', default: I18n.db_t(breakdown, default: breakdown))
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
        ethnicity_breakdown = {BREAKDOWN_ALL =>SUBJECT_ALL_PERCENTAGE}
        @school_cache_data_reader.ethnicity_data.each do | ed |
          # Two hacks for mapping pacific islander and native american to test scores values.
          if (PACIFIC_ISLANDER.include? ed['breakdown']) ||
              (PACIFIC_ISLANDER.include? ed['original_breakdown'])
            PACIFIC_ISLANDER.each { |islander| ethnicity_breakdown[islander] = ed['school_value']}
          elsif (NATIVE_AMERICAN.include? ed['breakdown']) ||
              (NATIVE_AMERICAN.include? ed['original_breakdown'])
            NATIVE_AMERICAN.each { |native_american| ethnicity_breakdown[native_american] = ed['school_value']}
          else
            ethnicity_breakdown[ed['breakdown']] = ed['school_value']
            ethnicity_breakdown[ed['original_breakdown']] = ed['school_value']
          end
        end
        ethnicity_breakdown.compact
      end
    end
  end
end
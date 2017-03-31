module SchoolProfiles

  class EthnicityPercentages
    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader
    end

    NATIVE_AMERICAN = [
        'American Indian/Alaska Native',
        'Native American'
    ]

    PACIFIC_ISLANDER = [
        'Pacific Islander',
        'Hawaiian Native/Pacific Islander',
        'Native Hawaiian or Other Pacific Islander'
    ]

    def ethnicities_to_percentages
      @_ethnicity_breakdowns = begin
        ethnicity_breakdown = {}

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

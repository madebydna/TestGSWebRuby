module SchoolProfiles

  class EthnicityPercentages
    def initialize(cache_data_reader:)
      @cache_data_reader = cache_data_reader
    end

    NATIVE_AMERICAN = [
        'American Indian/Alaska Native',
        'Native American',
        'Native American or Native Alaskan'
    ]

    PACIFIC_ISLANDER = [
        'Pacific Islander',
        'Hawaiian Native/Pacific Islander',
        'Native Hawaiian or Other Pacific Islander'
    ]

    AFRICAN_AMERICAN = [
      'African American',
      'Black'
    ]

    ASIAN = [
      'Asian or Pacific Islander',
      'Asian'
    ]

    def ethnicities_to_percentages
      @_ethnicity_breakdowns = begin
        ethnicity_breakdown = {}
        @cache_data_reader.ethnicity_data.each do | ed |
          # Two hacks for mapping pacific islander and native american to test scores values.
          if (PACIFIC_ISLANDER.include? ed['breakdown']) ||
              (PACIFIC_ISLANDER.include? ed['original_breakdown'])
            PACIFIC_ISLANDER.each { |islander| ethnicity_breakdown[islander] = ed["#{entity_type}_value"]}
          elsif (NATIVE_AMERICAN.include? ed['breakdown']) ||
              (NATIVE_AMERICAN.include? ed['original_breakdown'])
            NATIVE_AMERICAN.each { |native_american| ethnicity_breakdown[native_american] = ed["#{entity_type}_value"]}
          elsif (AFRICAN_AMERICAN.include? ed['breakdown']) ||
              (AFRICAN_AMERICAN.include? ed['original_breakdown'])
            AFRICAN_AMERICAN.each { |ethnicity| ethnicity_breakdown[ethnicity] = ed["#{entity_type}_value"]}
          elsif (ASIAN.include? ed['breakdown']) ||
              (ASIAN.include? ed['original_breakdown'])
            ASIAN.each { |ethnicity| ethnicity_breakdown[ethnicity] = ed["#{entity_type}_value"]}
          else
            ethnicity_breakdown[ed['breakdown']] = ed["#{entity_type}_value"]
            ethnicity_breakdown[ed['original_breakdown']] = ed["#{entity_type}_value"]
          end
        end
        ethnicity_breakdown.compact
      end
    end

    def entity_type
      @_entity_type ||= begin
        if @cache_data_reader.is_a?(DistrictCacheDataReader)
          'district'
        elsif @cache_data_reader.is_a?(SchoolCacheDataReader)
          'school'
        elsif @cache_data_reader.is_a?(StateCacheDataReader)
          'state'
        else
          raise NotImplementedError.new("@cache_data_reader must be valid in #{self.class.name}#entity_type")
        end
      end
    end
  end


end

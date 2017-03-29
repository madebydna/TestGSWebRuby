module SchoolProfiles
  class GraduationRateComponentGroup
    attr_reader :school_cache_data_reader, :components

    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader

      @components = [
        GraduationRate.new.tap do |component|
          component.school_cache_data_reader = school_cache_data_reader
          component.data_type = '4-year high school graduation rate'
          component.title = 'Graduation rates'
          component.type = 'bar'
          component.precision = 0
          component.display_percentages = true
        end,
        GraduationRate.new.tap do |component|
          component.school_cache_data_reader = school_cache_data_reader
          component.data_type = 'Percent of students who meet UC/CSU entrance requirements'
          component.title = 'UC/CSU eligibility'
          component.type = 'bar'
          component.precision = 0
          component.display_percentages = true
        end
      ]
    end

    def t(string)
      I18n.t(string, scope: 'lib.equity_gsdata', default: I18n.t(string, default: string))
    end

    def to_hash
      components.each_with_object({}) do |component, accum|
        accum[t(component.title)] = component.to_hash
      end
    end
  end

  class Component

    attr_accessor :school_cache_data_reader, :data_type, :title,
      :type, :precision, :display_percentages

    def filter_predicate(o)
      o[:score].present? &&
      (o[:breakdown] == 'All students' || ethnicity_breakdowns.key?(o[:breakdown]))
    end

    def comparator(h1, h2)
      return h2[:percentage].to_f <=> h1[:percentage].to_f
    end

    def to_hash
      {
        narration: narration,
        precision: precision,
        type: type,
        values: normalized_values
        .sort(&method(:comparator))
        .select(&method(:filter_predicate))
        .map do |h|
          {
            breakdown: t(h[:breakdown]),
            score: value_to_s(h[:score], precision),
            state_average: value_to_s(h[:state_average], precision),
            percentage: h[:percentage],
            display_percentages: true
          }
        end
      }
    end

    def value_to_s(value, precision=0)
      return nil if value.nil?
      num = value.to_f.round(precision)
      if precision.zero? && num < 1
        '<1'
      else
        num.to_s
      end
    end

    def percentage_str(percent)
      value = percent.to_f.round
      value < 1 ? '<1' : value.to_s
    end

    def t(string)
      I18n.t(string, scope: 'lib.equity_gsdata', default: I18n.t(string, default: string))
    end
  end

  class GraduationRate < Component
    def comparator(h1, h2)
      return -1 if h1[:breakdown] == 'All' || h1[:breakdown] == 'All students'
      return 1 if h2[:breakdown] == 'All' || h2[:breakdown] == 'All students'
      return h2[:percentage].to_f <=> h1[:percentage].to_f
    end

    def narration
      SchoolProfiles::NarrativeLowIncomeGradRateAndEntranceReq
      .new(school_cache_data_reader: school_cache_data_reader)
      .get_characteristics_low_income_narrative(data_type)
    end

    def normalized_values
      school_cache_data_reader
      .characteristics_data(data_type)
      .values
      .flatten
      .map { |h| normalize_characteristics_hash(h) }
    end

    # TODO: move somewhere more sensible, where it can be reused
    def normalize_characteristics_hash(hash)
      breakdown = hash['original_breakdown'] || hash['breakdown']
      {
        breakdown: breakdown,
        score: hash['school_value'],
        state_average: hash['state_average'],
        percentage: percentage_str(ethnicity_breakdowns[breakdown])
      }
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

    def ethnicity_breakdowns
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


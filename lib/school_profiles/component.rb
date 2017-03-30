module SchoolProfiles
  class Component
    attr_accessor :school_cache_data_reader, :data_type, :title, :type, :precision

    def initialize(precision: 0)
      @precision = precision
    end

    # Whether or not this component has enough data to be displayed
    def has_data?
      normalized_values.any? do |h|
        filter_predicate(h) &&
        h[:score].present? && h[:score].nonzero? && h[:score] != '0'
      end
    end

    # TODO: split into multiple methods?
    #
    # Returns true if the given score hash should be included in result
    def filter_predicate(h)
      h[:score].present? &&
      (h[:breakdown] == 'All students' || 
       ethnicities_to_percentages.key?(h[:breakdown]))
    end

    # By default, sort by percentage of study body, but keep "All" or "All
    # students" on top
    #
    # Keep in mind breakdown string must not be translated yet
    def comparator(h1, h2)
      return -1 if h1[:breakdown] == 'All students'
      return 1 if h2[:breakdown] == 'All students'
      return h2[:percentage].to_f <=> h1[:percentage].to_f
    end

    def to_hash
      {
        narration: narration,
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
            number_students_tested: h[:number_students_tested],
            display_percentages: true # TODO: true
          }
        end
      }
    end

    # TODO: refactor / test
    def value_to_s(value, precision=0)
      return nil if value.nil?
      return value.scan(/\d+/) if value.instance_of?(String) && value.present?
      num = value.to_f.round(precision)
      if precision.zero? && num < 1
        '<1'
      else
        num.to_s
      end
    end

    # abstract how to translate a string for this component
    def t(string)
      I18n.t(string, scope: 'lib.equity_gsdata', default: I18n.t(string, default: string))
    end

    # E.g.
    #
    # {
    #   'Asian' => 1.12345,
    #   'Hispanic' => 1.12345,
    #   ...
    # }
    def ethnicities_to_percentages
      SchoolProfiles::EthnicityPercentages.new(
        school_cache_data_reader: school_cache_data_reader
      ).ethnicities_to_percentages
    end
  end
end

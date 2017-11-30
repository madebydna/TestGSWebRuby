module SchoolProfiles
  module Components
    class Component
      attr_accessor :school_cache_data_reader, :data_type, :title, :type, :precision, :valid_breakdowns, :flagged
      attr_writer :narration

      def initialize(precision: 0)
        @precision = precision
      end

      def narration
        @narration || t(data_type, scope: 'lib.equity_gsdata.data_point_info_texts')
      end

      # Whether or not this component has enough data to be displayed
      def has_data?
        values.present?
      end

      def array_contains_any_valid_data?(array)
        array.any? do |h|
          (valid_breakdowns - ['All students']).include?(h[:breakdown]) && h[:score].present? && !float_value(h[:score]).zero?
        end
      end

      def rating_has_valid_data?(hash)
          (valid_breakdowns).include?(hash['breakdown']) && hash['school_value_float'].present? && !float_value(hash['school_value_float']).zero?
      end

      def valid_breakdowns
        @valid_breakdowns || ethnicities_to_percentages.keys + ['All students']
      end

      # TODO: split into multiple methods?
      #
      # Returns true if the given score hash should be included in result
      def filter_predicate(h)
        h[:score].present? && valid_breakdowns.include?(h[:breakdown])
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

      # formats and translates values in a hash before it goes to the view
      def standard_hash_to_value_hash_ratings(h)
        {
          breakdown: t(h['breakdown']),
          label: text_value(h['school_value_text']),
          score: float_value(h['school_value_float']),
          percentage: h['percentage'],
          display_percentages: true
        }
      end

      # formats and translates values in a hash before it goes to the view
      def standard_hash_to_value_hash(h)
        {
          breakdown: t(h[:breakdown]),
          label: text_value(h[:score]),
          score: float_value(h[:score]),
          state_average: float_value(h[:state_average]),
          state_average_label: text_value(h[:state_average]),
          percentage: h[:percentage],
          number_students_tested: h[:number_students_tested],
          grade: h[:grade],
          grades: h[:grades],
          display_percentages: true # TODO: true
        }
      end

      def values
        @_values ||= (
          array = normalized_values
            .select(&method(:filter_predicate))
          array = [] unless array_contains_any_valid_data?(array)
          array.sort(&method(:comparator))
            .map { |h| standard_hash_to_value_hash(h) }
        )
      end

      def to_hash
        {
          narration: narration,
          type: type,
          values: values,
          flagged: @flagged
        }
      end

      def float_value(value)
        return value if value.nil?
        float = value.to_s.scan(/[0-9.]+/).first.to_f
        float = float.round(precision) if precision
        float
      end

      def text_value(value)
        return value if value.nil?
        return '<1' if float_value(value) < 1
        # If a precision is set, and the value is a number, then just
        # use stringified float value
        if value.to_s == value.to_f.to_s && precision
          return float_value(value).to_s
        end
        return value.to_s
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
      def t(string, options = {})
        options = options.reverse_merge(
          scope: 'lib.equity_gsdata',
          default: I18n.t(string, default: string)
        )
        I18n.t(string, options)
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

      def low_income_to_percentages
        @_low_income_to_percentages ||= begin
          low_income = school_cache_data_reader.low_income_data.find {|ed| ed['breakdown'] == 'All students'}
          {
              'Economically disadvantaged' => low_income.present? ? low_income['school_value'] : nil
          }.compact
        end
      end

      def percentage_of_students_enrolled(breakdown)
        @_percentage_of_students_enrolled ||= begin
          hash = school_cache_data_reader.percentage_of_students(breakdown)
          {
            breakdown => hash['school_value']
          } if hash
        end
      end
    end
  end
end

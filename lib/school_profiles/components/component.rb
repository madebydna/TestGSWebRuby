module SchoolProfiles
  module Components
    class Component
      attr_accessor :school_cache_data_reader, :data_type, :title, :type, :precision, :valid_breakdowns
      attr_writer :narration

      def initialize(precision: 0)
        @precision = precision
      end

      def narration
        @narration || t(data_type, scope: 'lib.equity_gsdata.data_point_info_texts')
      end

      # Whether or not this component has enough data to be displayed
      def has_data?
        normalized_values.any? do |h|
          valid_breakdowns.include?(h[:breakdown]) && h[:score].present? && !float_value(h[:score]).zero?
        end
      end

      # TODO: split into multiple methods?
      #
      # Returns true if the given score hash should be included in result
      def filter_predicate(h)
        h[:score].present? &&
        (h[:breakdown] == 'All students' || 
         valid_breakdowns.include?(h[:breakdown]))
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
              label: text_value(h[:score]),
              score: float_value(h[:score]),
              state_average: float_value(h[:state_average]),
              state_average_label: text_value(h[:state_average]),
              percentage: h[:percentage],
              number_students_tested: h[:number_students_tested],
              display_percentages: true # TODO: true
            }
          end
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
    end
  end
end

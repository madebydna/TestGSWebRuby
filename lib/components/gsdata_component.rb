# frozen_string_literal: true

module Components
  class GsdataComponent < Component
    def normalized_values
      @_normalized_values ||= begin
        values = cache_data_reader.decorated_gsdata_data(data_type).having_school_value

        if valid_breakdowns.present?
          values = values.having_all_students_or_breakdown_in(valid_breakdowns)
        end
        if exact_breakdown_tags.present?
          values = values.for_all_students + values.having_exact_breakdown_tags(exact_breakdown_tags)
        end

        values = values.having_most_recent_date

        # By now only school values and breakdowns we're interested in remain
        # Throw away everything unless there's at least one subgroup now
        return [] unless values.any_subgroups? && array_contains_any_valid_data?(values)

        values
          .sort_by_breakdowns
          .map {|gs_data_value| gs_data_value_to_hash(gs_data_value)}
      end

      return @_normalized_values
    end

    def array_contains_any_valid_data?(gs_data_values)
      gs_data_values.having_non_zero_school_value.present?
    end

    def values
      @_values ||= begin
        normalized_values
          .sort(&method(:comparator))
      end
    end

    def gs_data_value_to_hash(dv)
      breakdown = (dv.breakdowns - ['All students except 504 category', 'General-Education students']).join(',').presence
      {
        breakdown: t(breakdown),
        label: text_value(dv.school_value),
        score: float_value(dv.school_value),
        state_average: float_value(dv.state_value),
        state_average_label: text_value(dv.state_value),
        percentage: breakdown_percentage(dv),
        number_students_tested: dv.school_cohort_count,
        grade: dv.grade,
        display_percentages: true,
        subject: dv.academics,
        test_description: dv.description,
        test_label: dv.data_type,
        test_source: dv.source_name,
        year: dv.year,
        state_number_tested: dv.state_cohort_count,
      }
    end

    def breakdown_percentage(dv)
      breakdown = (dv.breakdowns - ['All students except 504 category', 'General-Education students']).join(',')
      value_to_s(ethnicities_to_percentages[breakdown])
    end

  end
end


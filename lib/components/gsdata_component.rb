# frozen_string_literal: true

module Components
  class GsdataComponent < Component
    def normalized_values
      @_normalized_values ||= begin
        values = cache_data_reader.decorated_metrics_data(data_type).having_school_value
        if valid_breakdowns.present?
          values = values.having_all_students_or_breakdown_in(valid_breakdowns)
        end
        if exact_breakdown_tags.present?
          values = values.for_all_students + values.having_exact_breakdown_tags(exact_breakdown_tags)
        end
        if minimum_cutoff_year
          values = values.recent_data_threshold(minimum_cutoff_year)
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

    def has_data?
      !normalized_values.empty?
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
      breakdown = ['All students except 504 category', 'General-Education students'].include?(dv.breakdown) ? nil : dv.breakdown
      {
        breakdown: t(breakdown),
        label: text_value(dv.school_value),
        score: float_value(dv.school_value),
        state_average: float_value(dv.state_average),
        state_average_label: text_value(dv.state_average),
        percentage: breakdown_percentage(dv),
        grade: dv.grade,
        display_percentages: true,
        subject: dv.subject,
        test_label: dv.data_type,
        test_source: dv.source,
        year: dv.year
      }
    end

    def breakdown_percentage(dv)
      return if ['All students except 504 category', 'General-Education students'].include?(dv.breakdown)
      value_to_s(ethnicities_to_percentages[dv.breakdown])
    end

    def subject_name(data_type_name)
      I18n.t(data_type_name, scope: 'lib.equity_gsdata', default: data_type_name)
    end

    def source
      return {} if values.blank?
      {
          subject_name(data_type) => {
              info_text: I18n.t(data_type, scope: 'lib.equity_gsdata.data_point_info_texts', default: ''),
              sources: values.map { |dv| {name: dv[:test_source], year: dv[:year] }}.uniq
          }
      }
    end

  end
end


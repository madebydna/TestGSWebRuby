# frozen_string_literal: true

module Components
  module TestScores
    class StateTestScoresComponent < TestScoresComponent
      def narration
        t('RE Test scores narration', scope: 'lib.equity_gsdata', subject: t(data_type)) # TODO: update scope after moving translations
      end

      def normalized_values
        cache_data_reader
          .recent_test_scores
          .having_academic(data_type) # data type attribute actually contains the subject here
          .having_all_students_or_all_breakdowns_in(valid_breakdowns)
          .apply_to_each_data_type_academic_breakdown_group(&:keep_if_any_grade_all)
          .apply_to_each_data_type_academic_group(&:keep_if_any_non_zero_state_values)
          .group_by_data_type
          .each_with_object({}) do |(test, values_for_test), hash|
          hash[test] =
            values_for_test
              .sorted_subgroups # give us nested array. array for each breakdown incl All students
              .map do |values_for_subgroup|
              grade_all, other_grades = values_for_subgroup.separate_single_grade_all_from_other

              grade_all_rating_score_item = gs_data_value_to_hash(grade_all)

              if other_grades.present?
                grade_all_rating_score_item[:grades] =
                  other_grades.sort_by_grade.map do |gs_data_value|
                    gs_data_value_to_grade_hash(gs_data_value)
                  end
              end
              grade_all_rating_score_item
            end
        end
        # )
      end

      def values
        @_values ||= (
        normalized_values.each_with_object({}) do |(test_label, objects), hash|
          hash[test_label] = objects.sort(&method(:comparator))
        end
        )
      end

      def gs_data_value_to_hash(dv)
        {
          breakdown: t(dv.breakdown),
          label: text_value(dv.state_value),
          score: float_value(dv.state_value),
          percentage: breakdown_percentage(dv),
          # number_students_tested: dv.state_cohort_count,
          grade: dv.grade,
          display_percentages: true,
          subject: dv.academics,
          test_description: dv.description,
          test_label: dv.data_type,
          test_source: dv.source_name,
          year: dv.year
        }
      end

      def gs_data_value_to_grade_hash(gs_data_value)
        gs_data_value_to_hash(gs_data_value)
          .except(
            :breakdown,
            :subject,
            :test_description,
            :test_label,
            :test_source,
            :year,
            :state_number_tested
          )
      end

      def breakdown_percentage(dv)
        value_to_s(ethnicities_to_percentages[dv.breakdown])
      end

    end
  end
end

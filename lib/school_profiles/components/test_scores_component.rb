module SchoolProfiles
  module Components
    class TestScoresComponent < Component
      def narration
        t('RE Test scores narration', scope: 'lib.equity_gsdata', subject: t(data_type)) # TODO: update scope after moving translations
      end

      def normalized_values
        @_normalized_values ||= (
          values = school_cache_data_reader
            .flat_test_scores_for_latest_year
            .having_school_value
            .having_all_students_or_breakdown_in(valid_breakdowns)

          # By now only school values and breakdowns we're interested in remain
          # Throw away everything unless there's at least one subgroup now
          return [] unless values.any_subgroups?

          values
            .sort_by_breakdowns
            .group_by_breakdowns
            .values
            .select { |gs_data_values| array_contains_any_valid_data?(gs_data_values) }
            .map do |gs_data_values|
              grade_all_rating_score_item = gs_data_value_to_hash(
                gs_data_values
                .having_grade_all
                .expect_only_one('Expect only one value for all students grade all per test')
              )
              other_grades = gs_data_values.not_grade_all.sort_by_grade

              if other_grades.present?
                grade_all_rating_score_item[:grades] = other_grades.map do |gs_data_value|
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
              end
              grade_all_rating_score_item
            end
        )
      end

      def array_contains_any_valid_data?(gs_data_values)
        gs_data_values.having_non_zero_school_value.present?
      end

      def values
        @_values ||= (
          normalized_values
            .sort(&method(:comparator))
            .group_by { |h| h[:test_label] }
        )
      end

      def gs_data_value_to_hash(dv)
        {
          breakdown: t(dv.breakdown),
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
          state_number_tested: dv.state_cohort_count
        }
      end

      def breakdown_percentage(dv)
        value_to_s(ethnicities_to_percentages[dv.breakdown])
      end

    end
  end
end

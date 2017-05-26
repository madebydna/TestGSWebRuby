module SchoolProfiles
  module Components
    class TestScoresComponent < Component
      GRADES_DISPLAY_MINIMUM = 2

      def narration
        t('RE Test scores narration', scope: 'lib.equity_gsdata', subject: t(data_type)) # TODO: update scope after moving translations
      end

      def normalized_values
        @_normalized_values ||= (
          scores = school_cache_data_reader
            .flat_test_scores_for_latest_year
          (scores_grade_all, scores_grade_not_all) = scores.select { |h| h[:subject] == data_type }.partition { |score| score[:grade] == 'All' }
          scores_grade_all.map { |h| cache_hash_to_standard_hash(h, scores_grade_not_all) }
        )
      end

      def values
        @_values ||= (
          values_by_test_label = normalized_values
            .select(&method(:filter_predicate))
            .sort(&method(:comparator))
            .group_by { |h| h[:test_label] }

          values_by_test_label.keep_if do |test_label, values|
            array_contains_any_valid_data?(values)
          end

          values_by_test_label = values_by_test_label.each_with_object({}) do |(test_label, values), hash|
            hash[test_label] = values.map { |h| standard_hash_to_value_hash(h) }
          end
          values_by_test_label
        )
      end
      
      def cache_hash_to_standard_hash(hash, grades)
        breakdown = hash[:breakdown]
        grades_for_breakdown = grades.select{|grade| grade[:breakdown] == breakdown && grade[:test_label] == hash[:test_label]}
        normalized_breakdown = breakdown == 'All' ? 'All students' : breakdown
        hash.merge(
          breakdown: normalized_breakdown,
          percentage: breakdown_percentage(normalized_breakdown),
          grades: manage_grades_hash(grades_for_breakdown)
        )
      end

      def breakdown_percentage(breakdown)
        value_to_s(ethnicities_to_percentages[breakdown])
      end

      def manage_grades_hash(grades)
        grades.map do |grade|
          standard_hash_to_value_hash(grade).
              except(:breakdown,
                     :subject,
                     :test_description,
                     :test_label,
                     :test_source,
                     :year,
                     :state_number_tested)
        end if grades.present? && grades.count >= GRADES_DISPLAY_MINIMUM
      end
    end
  end
end

module SchoolProfiles
  class NarrativeLowIncomeTestScores
    def initialize(test_scores_hashes:)
      @test_scores_hashes = test_scores_hashes
    end

    def auto_narrative_calculate_and_add
      @test_scores_hashes.each_with_object({}) do |(data_type, array_of_gs_data_values), hash|
        hash[data_type] = add_to_array_of_hashes(array_of_gs_data_values)
      end
    end

    def add_to_array_of_hashes(array_of_gs_data_values)
      array_of_gs_data_values
        .having_grade_all
        .having_most_recent_date
        .group_by_academics.each_value do |gs_data_values|

          li_dv = gs_data_values
            .having_breakdown('Economically disadvantaged')
            .expect_only_one('Should only find one Economically disadvantaged value')

          nli_dv = gs_data_values
            .having_breakdown('Not economically disadvantaged')
            .expect_only_one('Should only find one Not economically disadvantaged value')

          all_dv = gs_data_values
            .for_all_students
            .expect_only_one('Should only find one value for All students')

          if li_dv && all_dv
            li_dv.narrative = low_income_text(
              self.class.yml_key(li_dv.school_value, li_dv.state_value,  all_dv.state_value),
              li_dv.academics
            )
          elsif nli_dv
            nli_dv.narrative = low_income_text('0', nli_dv.academics)
          end
        end
      array_of_gs_data_values
    end

    def self.yml_key(li_school_value, li_state_average, state_average)
      unless li_school_value && li_state_average && state_average
        return '0'
      end
      nf = SchoolProfiles::NarrationFormula.new

      column = nf.low_income_test_scores_calculate_column(
        li_state_average,
        li_school_value,
        state_average
      )

      if column.present?
        column
      else
        '0'
      end
    end

    def low_income_text(key, subject)
      subject_key = 'lib.test_scores.narrative.subject.' << subject
      full_key = 'lib.test_scores.narrative.low_income.' << key << '_html'
      # TODO: Consider db_t here?
      subject_tran = I18n.t(subject_key, default: subject)
      I18n.t(full_key, subject: subject_tran)
    end

    private

    def valid_school_cache_data_reader?
      @school_cache_data_reader.respond_to?(:test_scores) &&
        @school_cache_data_reader.test_scores.is_a?(Hash)
    end
  end
end

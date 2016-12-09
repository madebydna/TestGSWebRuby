module SchoolProfiles
  class NarrativeLowIncomeTestScores

    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader
    end

    def auto_narrative_calculate_and_add
      subjects = ['English Language Arts', 'Math']
      write_location = 'Economically disadvantaged'
      return nil unless valid_school_cache_data_reader?
      subjects.each do |subject|
        hash = hash_for_calculation '236', subject
        if hash['li'].present?
          year_to_use = year_to_use_from_hash hash
          yml_key = key_for_yml hash, year_to_use
          if year_to_use.present?
            write_to_test_score_hash '236', yml_key, subject, write_location, year_to_use
          end
        end
      end
    end

    def key_for_yml(hash, year_to_use)
      st_nli_avg = hash['nli'][year_to_use]['state_average']
      st_li_avg = hash['li'][year_to_use]['state_average']
      sch_nli_avg = hash['nli'][year_to_use]['score']
      sch_li_avg = hash['li'][year_to_use]['score']
      st_all_avg = hash['all'][year_to_use]['state_average']

      nf = SchoolProfiles::NarrationFormula.new
      column = nf.low_income_test_scores_calculate_column st_nli_avg, st_li_avg, sch_li_avg, st_all_avg
      row = nf.low_income_test_scores_calculate_row st_nli_avg, st_li_avg, sch_li_avg, sch_nli_avg

      if year_to_use.present? && column.present? && row.present?
        (column << '_' << row)
      else
        '0_0'
      end
    end

    def hash_for_calculation(data_id, subject)
      hash_breakdown = {'li' => 'Economically disadvantaged', 'nli' => 'Not economically disadvantaged', 'all'=>'All'}
      hash_breakdown.each do |key, value|
        hash_breakdown[key] = @school_cache_data_reader.test_scores.seek(data_id, value, 'grades', 'All', 'level_code', 'e,m,h', subject)
      end
    end

    # may want to go back a year from max to see if we can find a consistent year to use
    def year_to_use_from_hash(hash)
      if hash['li'].present? && hash['nli'].present? && hash['all'].present? && hash['li'].keys.max == hash['nli'].keys.max && hash['li'].keys.max == hash['all'].keys.max
        hash['li'].keys.max
      end
    end

    def write_to_test_score_hash(data_id, yml_key, subject, write_location, year_to_use)
      @school_cache_data_reader.test_scores[data_id][write_location]['grades']['All']['level_code']['e,m,h'][subject][year_to_use]['narrative'] = low_income_text(yml_key, subject)
    end

    def low_income_text(key, subject)
      subject_key = 'lib.test_scores.narrative.subject.' << subject
      full_key = 'lib.test_scores.narrative.low_income.' << key << '_html'
      subject_tran = I18n.t(subject_key)
      I18n.t(full_key, subject: subject_tran)
    end

    private

    def valid_school_cache_data_reader?
      @school_cache_data_reader.respond_to?(:test_scores) &&
        @school_cache_data_reader.test_scores.is_a?(Hash)
    end
  end
end

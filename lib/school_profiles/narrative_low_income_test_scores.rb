module SchoolProfiles
  class NarrativeLowIncomeTestScores

    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader
    end

    def auto_narrative_calculate_and_add
      return unless valid_school_cache_data_reader?

      @school_cache_data_reader.test_scores.each do |data_type_id, breakdown_hash|
        staging_hash(breakdown_hash).each do |level_code, subject_hash|
          subject_hash.each do |subject, hash|
            write_location = nil
            year_to_use = nil
            yml_key = '0_0'
            if hash['li'].present?
              write_location = 'Economically disadvantaged'
              year_to_use = hash['li'].keys.max
              yml_key = key_for_yml hash, year_to_use
            elsif hash['nli'].present?
              write_location = 'Not economically disadvantaged'
              year_to_use = hash['nli'].keys.max
            end
            unless write_location.nil?
              @school_cache_data_reader.test_scores[data_type_id][write_location]['grades']['All']['level_code'][level_code][subject][year_to_use]['narrative'] = low_income_text(yml_key, subject)
            end
          end
        end
      end
    end

    def staging_hash(breakdown_hash)
      staging_hash = {}
      hash_breakdown = {'li' => 'Economically disadvantaged', 'nli' => 'Not economically disadvantaged', 'all' => 'All'}
      hash_breakdown.each do |label, name|
        (breakdown_hash.seek(name, 'grades', 'All', 'level_code') || {}).each do |level_code, level_hash|
          staging_hash[level_code] ||= {}
          level_hash.each do |subject, value_hash|
            staging_hash[level_code][subject] ||= {}
            staging_hash[level_code][subject][label] = value_hash
          end
        end
      end
      staging_hash
    end

    def key_for_yml(hash, year_to_use)
      return_value = '0_0'
      if year_to_use.present? && hash_has_all_necessary_keys?(hash, year_to_use)
        st_nli_avg = hash['nli'][year_to_use]['state_average']
        st_li_avg = hash['li'][year_to_use]['state_average']
        sch_nli_avg = hash['nli'][year_to_use]['score']
        sch_li_avg = hash['li'][year_to_use]['score']
        st_all_avg = hash['all'][year_to_use]['state_average']

        nf = SchoolProfiles::NarrationFormula.new
        column = nf.low_income_test_scores_calculate_column st_nli_avg, st_li_avg, sch_li_avg, st_all_avg
        row = nf.low_income_test_scores_calculate_row st_nli_avg, st_li_avg, sch_li_avg, sch_nli_avg

        if year_to_use.present? && column.present? && row.present?
          return_value = (column << '_' << row)
        end
      end
      return_value
    end

    def yml_key(nli_school_value, nli_state_average, li_school_value, li_state_average, state_average)
      unless nli_school_value && nli_state_average && li_school_value && li_state_average && state_average
        return '0_0'
      end
      nf = SchoolProfiles::NarrationFormula.new

      column = nf.low_income_test_scores_calculate_column(
        nli_state_average,
        li_state_average,
        li_school_value,
        state_average
      )

      row = nf.low_income_test_scores_calculate_row(
        nli_state_average,
        li_state_average,
        li_school_value,
        nli_school_value
      )

      if column.present? && row.present?
        (column << '_' << row)
      else
        '0_0'
      end
    end

    def hash_has_all_necessary_keys?(hash, year)
      #  top level check
      if (hash_check_for_data? hash, year, 'li') && (hash_check_for_data? hash, year, 'nli') && (hash_check_for_data_key_all? hash, year)
        true
      else
        false
      end
    end

    def hash_check_for_data?(hash, year, type)
      if hash[type].present? && hash[type][year].present? && hash[type][year]['state_average'].present? && hash[type][year]['score'].present?
        true
      else
        false
      end
    end


    def hash_check_for_data_key_all?(hash, year)
      type = 'all'
      if hash[type].present? && hash[type][year].present? && hash[type][year]['state_average'].present?
        true
      else
        false
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

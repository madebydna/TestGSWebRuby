module SchoolProfiles
  class Equity
    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader
      SchoolProfiles::NarrativeLowIncomeGradRateAndEntranceReq.new(
          school_cache_data_reader: school_cache_data_reader
      ).auto_narrative_calculate_and_add
    end

    def data_type_id_based_on_hash
      @school_cache_data_reader.test_scores.each do |k, v|
        return k if v.gs_dig('Economically disadvantaged', 'grades', 'All','level_code', 'e,m,h', 'English Language Arts') ||
            v.gs_dig('Economically disadvantaged', 'grades', 'All','level_code', 'e,m,h', 'Math')
      end
    end

    def test_scores_by_ethnicity
      @_test_scores_by_ethnicity ||= (
        @school_cache_data_reader.test_scores[data_type_id_based_on_hash]
      )
    end

    def enrollment
      enrollment_string = @school_cache_data_reader.students_enrolled
      return enrollment_string.gsub(',','').to_i if enrollment_string
    end

    def characteristics
      @school_cache_data_reader.characteristics.slice(
        '4-year high school graduation rate',
        'Percent of students who meet UC/CSU entrance requirements'
      )
    end

    def characteristics_low_income_visible?
      visible = false
      if characteristics.present?
        characteristics.each do |data_type, data_hashes|
          data_hashes.each do |data|
            if data['breakdown'] == 'Economically disadvantaged'
              visible = true
              break
            end
          end
        end
      end
      visible
    end



    def rating_low_income
      @school_cache_data_reader.equity_ratings_breakdown('Economically disadvantaged')
    end

    def ethnicity_visible?
      test_scores_by_ethnicity.present? || characteristics['4-year high school graduation rate'].present? || characteristics['Percent of students who meet UC/CSU entrance requirements'].present?
    end

    def low_income_visible?
      #characteristics_low_income_visible? || test_scores_by_ethnicity.find{ |k,v| k == 'Economically disadvantaged' }    #test_scores_by_ethnicity.key?('Economically disadvantaged')
      if test_scores_by_ethnicity.present?
        test_scores_by_ethnicity.key?('Economically disadvantaged')
      else
        characteristics_low_income_visible?
      end

    end
  end
end

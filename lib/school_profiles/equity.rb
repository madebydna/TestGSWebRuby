module SchoolProfiles
  class Equity
    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader
      @data_type_id = '236'
      narration_content
    end

    def test_scores_by_ethnicity
      @school_cache_data_reader.test_scores[@data_type_id]
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

    def narration_content
      characteristics_low_income_narrative('4-year high school graduation rate')
      characteristics_low_income_narrative('Percent of students who meet UC/CSU entrance requirements')
    end

    def characteristics_low_income_narrative(data_type_name)
      if characteristics.present?
        characteristics.each do |data_type, data_hashes|
          if data_type == data_type_name
            data_hashes.each do |data|
              if data['breakdown'] == 'Economically disadvantaged'
                key_value = narration_calculation data_type_name, data
                data['narrative'] = low_income_narration key_value, data_type_name
              end
            end
          end
        end
      end
    end

    def low_income_narration(key, subject)
      full_key = 'lib.test_scores.narrative.' << subject << '.' << key << '_html'
      I18n.t(full_key)
    end

    def narration_calculation(data_type_name, data)
      sch_avg = data['school_value']
      st_avg = data['state_average']
      st_moe = 1
      if data_type_name == 'Percent of students who meet UC/CSU entrance requirements'
        very_low = 20
        narration_formula(sch_avg, st_avg, st_moe, very_low)
      elsif data_type_name == '4-year high school graduation rate'
        very_low = 10
        narration_formula(sch_avg, st_avg, st_moe, very_low)
      end
    end

    def narration_formula(sch_avg, st_avg, st_moe, very_low)
      if (st_avg - st_moe) - sch_avg > very_low
        '1'
      elsif (((st_avg - st_moe) - sch_avg <= very_low) && ((st_avg - st_moe) - sch_avg > 0))
        '2'
      elsif (((st_avg - st_moe) - sch_avg <= 0) && ((st_avg + st_moe) - sch_avg >= 0))
        '3'
      elsif ((st_avg + st_moe) - sch_avg < 0)
        '4'
      end
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

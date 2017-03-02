module SchoolProfiles
  class EquityTestScores

    SUBJECT_ALL_PERCENTAGE = '200' # This is also used in react to determine different layout in ethnicity for All students
    BREAKDOWN_LOW_INCOME = 'Economically disadvantaged'
    BREAKDOWN_NOT_LOW_INCOME = 'Not economically disadvantaged'
    BREAKDOWN_ALL = 'All'
    LOW_INCOME_TOP = 'low_income'
    ETHNICITY_TOP = 'ethnicity'

    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader
    end

    def generate_hash
      {
          LOW_INCOME_TOP => low_income_hash,
          ETHNICITY_TOP => ethnicity_hash
      }
    end



    # Methods shared by low income and ethnicity

    def test_scores_formatted(breakdown_arr)
      hash = equity_test_score_hash(breakdown_arr)
      year = year_latest_across_tests(hash)
      filter_by_latest_year(hash, year)
    end

    def equity_test_score_hash(inclusion_hash=low_income_breakdowns)
      output_hash = {}
      # for each test data_type_id
      @school_cache_data_reader.test_scores.values.each { |test_hash|
        #for each breakdown low income - eco and not eco
        breakdowns = test_hash.select{ |breakdown| inclusion_hash.keys.include? breakdown }
        breakdowns.each { | breakdown_name, breakdown_hash|
          level_code = breakdown_hash.seek('grades', 'All', 'level_code')
          level_code.first[1].each {|subject, year_hash|
            year = latest_year_in_test(year_hash).to_s
            subject_str = I18n.t(subject, scope: 'lib.school_cache_data_reader', default: subject)
            breakdown_name_str = I18n.t(breakdown_name, scope: 'lib.school_cache_data_reader', default: breakdown_name)
            output_hash[subject_str] ||= []
            output_hash[subject_str] << year_hash[year].merge({'breakdown'=>breakdown_name_str,
                                                               'year'=>year,
                                                               'percentage'=> percentage_str(inclusion_hash[breakdown_name])})
          } if level_code
        }
      }
      output_hash
    end

    def percentage_str(percent)
      value = percent.to_f.round
      value < 1 ? '<1' : value.to_s
    end

    def filter_by_latest_year(hash, year)
      hash.select {|subject,data| data.first['year'] == year }.to_h
    end

    def latest_year_in_test(year_hash)
      year_hash.keys.max_by { |year| year.to_i }
    end

    def year_latest_across_tests(hash)
      temp = []
      hash.each{|subject, data| data.each{| d | temp << d['year']}}
      temp.max
    end



    # Low income specific methods

    def low_income_sort_subjects(hash)
      hash.sort do | a, b |
        sum1 = b[1].inject(0){|a,e| a + e['number_students_tested'] }
        sum2 = a[1].inject(0){|a,e| a + e['number_students_tested'] }
        sum1 <=> sum2
      end
    end

    def low_income_sort_breakdowns(hash)
      hash.values.each{|data| data.sort!{|a,b| a['breakdown'] <=> b['breakdown']; } }
    end

    def low_income_hash
      hash = test_scores_formatted(low_income_breakdowns)
      sorted = low_income_sort_subjects(hash).to_h
      low_income_sort_breakdowns(sorted)
      hash
    end

    def low_income_breakdowns
      {BREAKDOWN_LOW_INCOME=>'0', BREAKDOWN_NOT_LOW_INCOME=>'0'}
    end



    # Ethnicity specific methods

    def ethnicity_sort_subjects(hash)
      hash.sort do | a, b |
        sum1 = b[1].first['number_students_tested'].to_i
        sum2 = a[1].first['number_students_tested'].to_i
        sum1 <=> sum2
      end
    end

    def ethnicity_sort_breakdowns(hash)
      hash.values.each{|data| data.sort_by!{|a| -a['percentage'].to_i  } }
    end

    def ethnicity_hash
      hash = test_scores_formatted(ethnicity_breakdowns)
      sorted = ethnicity_sort_subjects(hash).to_h
      ethnicity_sort_breakdowns(sorted)
      hash
    end

    def ethnicity_breakdowns
      ethnicity_breakdown = {BREAKDOWN_ALL=>SUBJECT_ALL_PERCENTAGE}
      @school_cache_data_reader.ethnicity_data.each do | ed |
        ethnicity_breakdown[ed['breakdown']] = ed['school_value']
        ethnicity_breakdown[ed['original_breakdown']] = ed['school_value']
      end
      ethnicity_breakdown.compact
    end

  end
end

module SchoolProfiles
  class EquityTestScores

    SUBJECT_ALL_PERCENTAGE = '200' # This is also used in react to determine different layout in ethnicity for All students
    BREAKDOWN_LOW_INCOME = 'Economically disadvantaged'
    BREAKDOWN_NOT_LOW_INCOME = 'Not economically disadvantaged'
    BREAKDOWN_ALL = 'All'
    LOW_INCOME_TOP = 'low_income'
    ETHNICITY_TOP = 'ethnicity'
    DISABILITIES_TOP = 'disabilities'
    SUBJECTS_TO_RETURN = 3
    NATIVE_AMERICAN = [
        'American Indian/Alaska Native',
        'Native American'
    ]

    PACIFIC_ISLANDER = [
        'Pacific Islander',
        'Hawaiian Native/Pacific Islander',
        'Native Hawaiian or Other Pacific Islander'
    ]
    # BREAKDOWN_PACIFIC_ISLANDER_COMBO = 'Native Hawaiian or Other Pacific Islander'
    # BREAKDOWN_PACIFIC_ISLANDER = 'Pacific Islander'
    # BREAKDOWN_HAWAIIAN = 'Hawaiian'
    BREAKDOWN_DISABILITIES = 'Students with disabilities'

    #PUBLIC

    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader
    end

    def generate_equity_test_score_hash
      # require 'pry'; binding.pry
      @_generate_equity_test_score_hash ||=({
          LOW_INCOME_TOP => low_income_hash,
          ETHNICITY_TOP => ethnicity_hash,
          DISABILITIES_TOP => disabilities_hash
      })
    end

    def low_income_test_scores_visible?
      low_income_hash.present?
    end

    def ethnicity_test_scores_visible?
      ethnicity_hash.present?
    end


    #PRIVATE
    # Methods shared by low income and ethnicity

    def test_scores_formatted(breakdown_arr)
      hash = equity_test_score_hash(breakdown_arr)
      year = year_latest_across_tests(hash)
      filter_by_latest_year(hash, year)
    end

    def equity_test_score_hash(inclusion_hash=low_income_breakdowns)
      output_hash = {}
      # for each test data_type_id
      @school_cache_data_reader.test_scores.values.each do |test_hash|
        breakdowns = test_hash.select{ |breakdown| inclusion_hash.keys.include? breakdown }
        breakdowns.each do | breakdown_name, breakdown_hash|
          level_code = breakdown_hash.seek('grades', 'All', 'level_code')
          level_code.first[1].each do |subject, year_hash|
            year = latest_year_in_test(year_hash).to_s
            subject_str = I18n.t(subject, scope: 'lib.equity_test_scores', default: I18n.db_t(subject, default: subject))
            breakdown_name_str = I18n.t(breakdown_name, scope: 'lib.equity_test_scores', default: I18n.db_t(breakdown_name, default: breakdown_name))
            output_hash[subject_str] ||= []
            output_hash[subject_str] << year_hash[year].merge({'breakdown'=>breakdown_name_str,
                                                               'display_percentages'=>display_percentages(breakdown_name),
                                                               'year'=>year,
                                                               'percentage'=> percentage_str(inclusion_hash[breakdown_name]),
                                                               'score'=> scores_format_numbers(year_hash[year]['score']),
                                                               'state_average'=> scores_format_numbers(year_hash[year]['state_average'])})
          end if level_code
        end
      end
      output_hash
    end

    def display_percentages(breakdown_name)
      low_income_breakdowns.exclude? breakdown_name
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

    def scores_format_numbers(value)
      if value.respond_to?(:round)
        value.round
      elsif value.instance_of? String
        value.scan(/\d+/) if value.present?
      else
        value
      end
    end



    # Low income specific methods

    def low_income_sort_subjects(hash)
      hash.sort do | a, b |
        sum1 = sum2 = 0
        if b.present? && b[1].present? && a.present? && a[1].present?
          sum1 = b[1].inject(0){|a,e| a + e['number_students_tested'] if e['number_students_tested']} || 0
          sum2 = a[1].inject(0){|a,e| a + e['number_students_tested'] if e['number_students_tested']} || 0
        end
        sum1 <=> sum2
      end
    end

    def low_income_sort_breakdowns(hash)
      hash.values.each{|data| data.sort!{|a,b| a['breakdown'] <=> b['breakdown']; }[0..2] }
    end

    def low_income_hash
      @_low_income_hash ||=(
        hash = test_scores_formatted(low_income_breakdowns)
        sorted = low_income_sort_subjects(hash).to_h
        low_income_sort_breakdowns(sorted)
        sorted.first(SUBJECTS_TO_RETURN).to_h
      )
    end

    def low_income_breakdowns
      {BREAKDOWN_LOW_INCOME=>'0', BREAKDOWN_NOT_LOW_INCOME=>'0'}
    end

    # disability

    def disabilities_hash
      @_disabilities_hash ||=(
      hash = test_scores_formatted(disabilities_breakdowns)
      # sorted = low_income_sort_subjects(hash).to_h
      # low_income_sort_breakdowns(sorted)
      hash.first(SUBJECTS_TO_RETURN).to_h
      )
    end

    def disabilities_breakdowns
      {BREAKDOWN_DISABILITIES => '0'}
    end

    # Ethnicity specific methods

    def ethnicity_sort_subjects(hash)
      hash.sort do | a, b |
        b[1].first['number_students_tested'].to_i <=> a[1].first['number_students_tested'].to_i
      end
    end

    def ethnicity_sort_breakdowns(hash)
      hash.values.each{|data| data.sort_by!{|a| -a['percentage'].to_i  } }
    end

    def ethnicity_hash
      @_ethnicity_hash ||=(
        hash = test_scores_formatted(ethnicity_breakdowns)
        sorted = ethnicity_sort_subjects(hash).to_h
        ethnicity_sort_breakdowns(sorted)
        sorted = ethnicity_filter_all_with_no_other_breakdowns(sorted)
        sorted.first(SUBJECTS_TO_RETURN).to_h
      )
    end

    # find any subject where there is only one and kill it
    def ethnicity_filter_all_with_no_other_breakdowns(hash)
      hash.delete_if { |key, data| data.count == 1 }
    end

    def ethnicity_breakdowns
      ethnicity_breakdown = {BREAKDOWN_ALL=>SUBJECT_ALL_PERCENTAGE}
      @school_cache_data_reader.ethnicity_data.each do | ed |
        if (PACIFIC_ISLANDER.include? ed['breakdown']) ||
            (PACIFIC_ISLANDER.include? ed['original_breakdown'])
          PACIFIC_ISLANDER.each { |islander| ethnicity_breakdown[islander] = ed['school_value']}
        elsif (NATIVE_AMERICAN.include? ed['breakdown']) ||
            (NATIVE_AMERICAN.include? ed['original_breakdown'])
          NATIVE_AMERICAN.each { |native_american| ethnicity_breakdown[native_american] = ed['school_value']}
        else
          ethnicity_breakdown[ed['breakdown']] = ed['school_value']
          ethnicity_breakdown[ed['original_breakdown']] = ed['school_value']
        end
      end
      ethnicity_breakdown.compact
    end

  end
end

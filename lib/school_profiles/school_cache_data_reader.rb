module SchoolProfiles
  class SchoolCacheDataReader
    # ratings - for gs rating
    # characteristics - for enrollment
    # reviews_snapshot - for review info in the profile hero
    # nearby_schools - for nearby schools module
    SCHOOL_CACHE_KEYS = %w(ratings characteristics reviews_snapshot test_scores nearby_schools performance gsdata)

    attr_reader :school, :school_cache_keys

    def initialize(school, school_cache_keys: SCHOOL_CACHE_KEYS)
      self.school = school
      @school_cache_keys = school_cache_keys
    end

    def decorated_school
      @_decorated_school ||= decorate_school(school)
    end

    def cache_updated_dates
      decorated_school.cache_data.select { |k, _| k.match(/^_.*_updated$/) }.values.compact
    end

    def gs_rating
      ((1..10).to_a & [decorated_school.great_schools_rating]).first
    end

    def gs_rating_year
      decorated_school.great_schools_rating_year
    end

    def students_enrolled
      decorated_school.students_enrolled
    end

    def five_star_rating
      decorated_school.star_rating
    end

    def number_of_active_reviews
      decorated_school.num_reviews
    end

    def num_ratings
      decorated_school.num_ratings
    end

    def test_scores_rating
      decorated_school.test_scores_rating
    end

    def college_readiness_rating
      decorated_school.college_readiness_rating
    end

    def college_readiness_rating_year
      decorated_school.college_readiness_rating_year
    end

    def equity_ratings_breakdown(breakdown)
      if decorated_school.performance && decorated_school.performance['GreatSchools rating']
        breakdown_results = decorated_school.performance['GreatSchools rating'].select { |bd|
          bd['breakdown'] == breakdown
        }
        if breakdown_results.is_a?(Array) && !breakdown_results.empty?
               breakdown_results.first['school_value']
        end
      end
    end

    def ethnicity_data
      decorated_school.ethnicity_data
    end

    def characteristics_data(*keys)
      decorated_school.characteristics.slice(*keys)
    end

    def nearby_schools
      decorated_school.nearby_schools
    end

    def test_scores
      decorated_school.test_scores
    end

    def graduation_rate_data
      decorated_school.characteristics['4-year high school graduation rate']
    end

    def characteristics
      decorated_school.characteristics
    end

    def gsdata_data(*keys)
      decorated_school.gsdata.slice(*keys)
    end

    def sources_with_subjects(breakdown: 'All', grades: 'All')
      @_sources_with_subjects ||= (

      )
    end

    def low_income_breakdowns
      {'Economically disadvantaged'=>'0', 'Not economically disadvantaged'=>'0'}
    end

    def ethnicity_breakdowns
      ethnicity_breakdown = {'All'=>'200'}
      ethnicity_data.each{ | ed |  ethnicity_breakdown[ed['breakdown']] = ed['school_value']; ethnicity_breakdown[ed['original_breakdown']] = ed['school_value']; }
      ethnicity_breakdown.compact
    end

    def equity_test_scores
      @_equity_test_scores ||=(
        {
          'low_income' => low_income_hash,
          'ethnicity' => ethnicity_hash
        }
      )
    end

    def low_income_hash
      hash = test_scores_formatted(low_income_breakdowns)
      low_income_sort_hash(hash)
      hash
    end

    def ethnicity_hash
      hash = test_scores_formatted(ethnicity_breakdowns)
      ethnicity_sort_hash(hash)
      hash
    end

    def low_income_sort_hash(hash)
      hash.values.each{|data| data.sort!{|a,b| a['breakdown'] <=> b['breakdown']; } }
    end
    def ethnicity_sort_hash(hash)
      hash.values.each{|data| data.sort_by!{|a| -a['percentage'].to_i  } }
    end

    def test_scores_formatted(breakdown_arr)
      hash = equity_test_score_hash(breakdown_arr)
      sorted = equity_test_score_hash_sort_by_number_students_tested(hash)
      year = year_latest_across_tests(sorted)
      equity_test_score_filter_by_latest_year(sorted, year)
    end

    def latest_year_in_test(year_hash)
      year_hash.keys.max_by { |year| year.to_i }
    end

    def equity_test_score_hash(inclusion_hash=low_income_breakdowns)
      output_hash = {}
      # for each test data_type_id
      test_scores.values.each { |test_hash|
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

    def equity_test_score_filter_by_latest_year(hash, year)
      hash.select {|subject| subject[1].first['year'] == year }.to_h
    end

    def year_latest_across_tests(hash)
      temp = []
      hash.each{|subject, data| data.each{| d | temp << d['year']}}
      temp.max
    end

    def equity_test_score_hash_sort_by_number_students_tested(hash)
      hash.sort {| a, b |
        sum1 = b[1].inject(0){|a,e| a + e['number_students_tested'] }
        sum2 = a[1].inject(0){|a,e| a + e['number_students_tested'] }
        sum1 <=> sum2
      }
    end


    def subject_scores_by_latest_year(breakdown: 'All', grades: 'All', level_codes: nil, subjects: nil)
      @_subject_scores_by_latest_year ||= (
        subject_hash = test_scores.map do |data_type_id, v|
          level_code_obj = v.seek(breakdown, 'grades', grades, 'level_code')
          if level_code_obj.present?
            level_code_obj.compact.each_with_object({}) do |input_hash, output_hash|
              input_hash[1].each do |subject, year_hash|
                latest_year = year_hash.keys.max_by { |year| year.to_i }
                output_hash[subject] ||= {}
                val = test_scores[data_type_id.to_s][breakdown]
                year_hash[latest_year.to_s]['test_description'] = val['test_description']
                year_hash[latest_year.to_s]['test_label']       = val['test_label']
                year_hash[latest_year.to_s]['test_source']      = val['test_source']
                output_hash[subject]
                output_hash[subject].merge!(year_hash)
              end
              output_hash
            end
          end
        end

        return [] unless subject_hash.present?
        subject_hash = subject_hash.compact.inject(:merge)
        subject_hash.select! { |subject, _| subjects.include?(subject) } if subjects.present?
        subject_hash.inject([]) do |scores_array, (subject, year_hash)|
          scores_array << OpenStruct.new({}.tap do |scores_hash|
            latest_year = year_hash.keys.max_by { |year| year.to_i }
            scores_hash.merge!(year_hash[latest_year.to_s])
            scores_hash['subject'] = subject
            scores_hash['year'] = latest_year
          end)
        end)
    end

    def school_cache_query
      SchoolCacheQuery.for_school(school).tap do |query|
        query.include_cache_keys(school_cache_keys)
      end
    end

    def decorate_school(school)
      query_results = school_cache_query.query
      school_cache_results = SchoolCacheResults.new(SCHOOL_CACHE_KEYS, query_results)
      school_cache_results.decorate_school(school)
    end

    private

    def school=(school)
      raise ArgumentError('School must be provided') if school.nil?
      @school = school
    end
  end
end

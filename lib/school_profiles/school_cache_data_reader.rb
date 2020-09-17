module SchoolProfiles
  class SchoolCacheDataReader
    # ratings - for gs rating
    # metrics - for enrollment
    # reviews_snapshot - for review info in the profile hero
    # nearby_schools - for nearby schools module
    SCHOOL_CACHE_KEYS = %w(ratings metrics reviews_snapshot test_scores_gsdata nearby_schools performance esp_responses)
    DISCIPLINE_FLAG = 'Discipline Flag'
    ABSENCE_FLAG = 'Absence Flag'
    EQUITY_ADJUSTMENT_FACTOR = 'Equity Adjustment Factor'
    CSA_BADGE = 'CSA Badge'

    attr_reader :school, :school_cache_keys

    def initialize(school, school_cache_keys: SCHOOL_CACHE_KEYS)
      self.school = school
      @school_cache_keys = school_cache_keys
    end

    def school_state
      school.state
    end

    def decorated_school
      @_decorated_school ||= decorate_school(school)
    end

    def cache_updated_dates
      decorated_school.cache_data.select { |k, _| k.match(/^_.*_updated$/) }.values.compact
    end

    def gs_rating
      @_gs_rating ||= (
        summary_rating = ((1..10).to_a & [decorated_school.great_schools_rating]).first
        test_score_weight = (rating_weights.fetch('Summary Rating Weight: Test Score Rating', []).first || {})['school_value']
        if summary_rating.nil? && test_score_weight == '1'
          decorated_school.test_scores_rating
        else
          summary_rating
        end
      )
    end

    def state_attributes
      @_state_attributes ||= StateCache.for_state('state_attributes', school.state)&.cache_data || {}
    end

    # Data growth type. Either a Data Growth Type (Student Progress Rating)
    # or Data Growth Proxy Type (Academic Progress Rating)
    def growth_type
      @_growth_type ||= state_attributes.fetch('growth_type',nil)
    end

    def hs_enabled_growth_rating?
      state_attributes.fetch('hs_enabled_growth_rating', nil)
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

    def historical_test_scores_ratings
      decorated_school.historical_test_scores_ratings
    end

    def college_readiness_rating
      decorated_school.college_readiness_rating
    end

    def college_readiness_rating_year
      decorated_school.college_readiness_rating_year
    end

    def historical_college_readiness_ratings
      decorated_school.historical_college_readiness_ratings
    end

    def student_progress_rating
      decorated_school.student_growth_rating
    end

    def student_progress_rating_year
      decorated_school.student_growth_rating_year
    end

    def student_progress_rating_hash
      decorated_school.student_growth_rating_hash
    end

    def college_readiness_rating_hash
      decorated_school.college_readiness_rating_hash
    end

    def test_scores_rating_hash
      decorated_school.test_scores_rating_hash
    end

    def test_scores_all_rating_hash
      decorated_school.test_scores_all_rating_hash
    end

    def state_equity_rating?
      state_attributes.fetch('equity_rating', nil)
    end

    def equity_overview_rating
      decorated_school.equity_overview_rating
    end

    def equity_overview_rating_hash
      decorated_school.equity_overview_rating_hash
    end

    def equity_overview_rating_year
      decorated_school.equity_overview_rating_year
    end

    def equity_overview_data
      decorated_school.equity_overview_data
    end

    def academic_progress_rating
      decorated_school.academic_progress_rating
    end

    def academic_progress_rating_hash
      decorated_school.academic_progress_rating_hash
    end

    def academic_progress_rating_year
      decorated_school.academic_progress_rating_year
    end

    def historical_student_progress_ratings
      decorated_school.historical_student_growth_ratings
    end

    def advanced_courses_rating
      decorated_school.courses_rating
    end

    def equity_ratings_breakdown(breakdown)
      if decorated_school.test_scores_all_rating_hash
        breakdown_results = decorated_school.test_scores_all_rating_hash.select { |bd|
          bd['breakdown'] == breakdown
        }
        if breakdown_results.is_a?(Array) && !breakdown_results.empty?
          breakdown_results.first['school_value_float']
        end
      end
    end

    def ethnicity_data
      decorated_school.ethnicity_data
    end

    def low_income_data
      decorated_school.free_or_reduced_price_lunch_data
    end

    def decorated_metrics_datas(*keys)
      decorated_school.metrics.slice(*keys).each_with_object({}) do |(data_type, array), accum|
        accum[data_type] =
          array.map do |h|
            MetricsCaching::Value.from_hash(h).tap {|dv| dv.data_type = data_type}
          end.extend(MetricsCaching::Value::CollectionMethods)
      end
    end

    def decorated_metrics_data(key)
      Array.wrap(decorated_school.metrics.slice(key)[key])
        .map do |h|
        MetricsCaching::Value.from_hash(h).tap {|dv| dv.data_type = key }
      end.extend(MetricsCaching::Value::CollectionMethods)
    end

    def nearby_schools
      decorated_school.nearby_schools
    end

    def test_scores
      decorated_school.test_scores
    end

    def flat_test_scores_for_latest_year
      hashes = test_scores.each_with_object([]) do |(data_type, array_of_hashes), array|
        array.concat(
          array_of_hashes.map do |test_scores_hash|
            {
              data_type: data_type,
              description: test_scores_hash['description'],
              source_name: test_scores_hash['source_name'],
              breakdowns: test_scores_hash['breakdowns'],
              breakdown_tags: test_scores_hash['breakdown_tags'],
              source_date_valid: test_scores_hash['source_date_valid'],
              academics: test_scores_hash['academics'],
              grade: test_scores_hash['grade'],
              flags: test_scores_hash['flags'],
              school_value: test_scores_hash['school_value'],
              school_cohort_count: test_scores_hash['school_cohort_count'],
              state_cohort_count: test_scores_hash['state_cohort_count'],
              state_value: test_scores_hash['state_value'],
            }
          end
        )
      end
      GsdataCaching::GsDataValue.from_array_of_hashes(hashes).having_most_recent_date
    end

    def recent_test_scores
      flat_test_scores_for_latest_year
        .having_school_value
        .sort_by_cohort_count
        .having_academics
    end

    def recent_test_scores_without_subgroups
      recent_test_scores
        .for_all_students
    end

    def metrics
      decorated_school.metrics
    end

    def ratings_data(*keys)
      gs_data(decorated_school.ratings, *keys)
    end

    def gs_data(obj, *keys)
      obj.slice(*keys).each_with_object({}) do |(k, values), new_hash|
        values = values.map(&consistify_breakdowns)
        new_hash[k] = values
      end
    end

    def consistify_breakdowns
      lambda do |h|
        h = h.clone
        if h['breakdowns']
          h['breakdowns'] = h['breakdowns'].gsub('All students except 504 category,','')
          h['breakdowns'] = h['breakdowns'].gsub(/,All students except 504 category$/,'')
          h['breakdowns'] = h['breakdowns'].gsub('All Students','All students')
        end
        h
      end
    end

    def rating_weights
      decorated_school.ratings.select do |key, val|
        key.include?('Summary Rating Weight')
      end
    end

    def rating_weight_values_array
      rating_weight_hash = decorated_school.ratings.select {|key, val| key.include?('Summary Rating Weight')}
      return nil if rating_weight_hash.empty?
      rating_weight_hash.values.map  do |weight_data|
        return nil if (weight_data.all? {|hash| hash.nil? || hash['school_value'].nil?})
        ((weight_data.max_by {|dh| dh['source_date_valid']}['school_value'].to_f)*100).round
      end
    end

    def build_time_object(dt_string)
      begin
      year = dt_string[0..3]
      month = dt_string[4..5]
      day = dt_string[6..7]
      hour = dt_string[9..10]
      minute = dt_string[11..12]
      Time.new(year, month, day, hour, minute)
      rescue StandardError => error
        GSLogger.error(:summary_rating, error, vars: {school: decorated_school.id, state: decorated_school.state}, message: 'Error creating Time object using source_date_time value for Summary Rating')
        nil
      end
    end

    def format_date(dt_object)
      dt_object.strftime('%b %d, %Y')
    end

    def discipline_flag?
      @_discipline_flag ||= (
        flag_data_value = discipline_attendance_data_values[DISCIPLINE_FLAG]
        flag_data_value.present? && flag_data_value.school_value == '1'
      )
    end

    def attendance_flag?
      @_attendance_flag ||= (
        flag_data_value = discipline_attendance_data_values[ABSENCE_FLAG]
        flag_data_value.present? && flag_data_value.school_value == '1'
      )
    end

    def equity_adjustment_factor?
      @_equity_adjustment_factor ||= (
        ratings_data(EQUITY_ADJUSTMENT_FACTOR).present?
      )
    end

    def discipline_attendance_data_values
      @_discipline_attendance_data_values ||= (
        data_hashes = ratings_data(DISCIPLINE_FLAG, ABSENCE_FLAG)
        data_hashes.each_with_object({}) do |(data_type_name, array_of_hashes), output_hash|
          most_recent_all_students = array_of_hashes
            .map { |hash| GsdataCaching::GsDataValue.from_hash(hash.merge(data_type: data_type_name)) }
            .extend(GsdataCaching::GsDataValue::CollectionMethods)
            .for_all_students
            .most_recent
          output_hash[data_type_name] = most_recent_all_students if most_recent_all_students
        end
      )
    end

    def csa_badge?
      decorated_school.ratings.has_key?(CSA_BADGE)
    end

    def csa_awards
      decorated_school.ratings[CSA_BADGE]
    end

    # Returns a hash that includes the percentage and sourcing info
    # {
    #   "breakdowns": "Students with disabilities",
    #   "breakdown_tags": "disability",
    #   "school_value": "11.59",
    #   "source_year": 2014,
    #   "source_name": "Civil Rights Data Collection"
    # }
    def percentage_of_students(breakdown)
      percentages = (
        decorated_school.metrics.slice('Percentage of Students Enrolled') || {}
      ).fetch('Percentage of Students Enrolled', [])
      percentages.find { |h| h['breakdowns'] == breakdown }
    end

    def esp_responses_data(*keys)
      decorated_school.programs.slice(*keys)
    end

    def sources_with_subjects(breakdown: 'All', grades: 'All')
      @_sources_with_subjects ||= (

      )
    end

    def subject_scores_by_latest_year(breakdown: 'All', grades: 'All', level_codes: nil, subjects: nil)
      @_subject_scores_by_latest_year ||= (
        subject_hash = test_scores.map do |data_type_id, v|
          level_code_obj = v.seek(breakdown, 'grades', grades, 'level_code')
          if level_code_obj.present?
            level_code_obj.compact.each_with_object({}) do |input_hash, output_hash|
              input_hash[1].each do |subject, year_hash|
                latest_year = year_hash.keys.max_by { |year| year.to_i }
                next if year_hash[latest_year]['score'].nil?
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

        subject_hash.compact!
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
      query_results = school_cache_query.query_and_use_cache_keys
      school_cache_results = SchoolCacheResults.new(SCHOOL_CACHE_KEYS, query_results)
      school_cache_results.decorate_school(school)
    end

    private

    def school=(school)
      raise ArgumentError.new('School must be provided') if school.nil?
      @school = school
    end
  end
end

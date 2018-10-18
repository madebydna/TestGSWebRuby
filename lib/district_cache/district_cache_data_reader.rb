# frozen_string_literal: true

class DistrictCacheDataReader
  DISTRICT_CACHE_KEYS = %w(feed_test_scores_gsdata test_scores_gsdata feed_test_scores ratings district_districts_summary district_directory feed_district_characteristics district_characteristics)

  attr_reader :district, :district_cache_keys

  def initialize(district, district_cache_keys: DISTRICT_CACHE_KEYS)
    self.district = district
    @district_cache_keys = district_cache_keys
  end

  def decorated_district
    @_decorated_district ||= decorate_district(district)
  end

  def cache_updated_dates
    decorated_district.cache_data.select {|k, _| k.match(/^_.*_updated$/)}.values.compact
  end

  def students_enrolled
    decorated_district.students_enrolled
  end

  def five_star_rating
    decorated_district.star_rating
  end

  def number_of_active_reviews
    decorated_district.num_reviews
  end

  def num_ratings
    decorated_district.num_ratings
  end

  def test_scores_rating
    decorated_district.test_scores_rating
  end

  def historical_test_scores_ratings
    decorated_district.historical_test_scores_ratings
  end

  def college_readiness_rating
    decorated_district.college_readiness_rating
  end

  def college_readiness_rating_year
    decorated_district.college_readiness_rating_year
  end

  def historical_college_readiness_ratings
    decorated_district.historical_college_readiness_ratings
  end

  def student_progress_rating
    decorated_district.student_growth_rating
  end

  def student_progress_rating_year
    decorated_district.student_growth_rating_year
  end

  def student_progress_rating_hash
    decorated_district.student_growth_rating_hash
  end

  def college_readiness_rating_hash
    decorated_district.college_readiness_rating_hash
  end

  def test_scores_rating_hash
    decorated_district.test_scores_rating_hash
  end

  def test_scores_all_rating_hash
    decorated_district.test_scores_all_rating_hash
  end

  def equity_overview_rating
    decorated_district.equity_overview_rating
  end

  def equity_overview_rating_hash
    decorated_district.equity_overview_rating_hash
  end

  def equity_overview_rating_year
    decorated_district.equity_overview_rating_year
  end

  def courses_rating
    decorated_district.courses_rating
  end

  def courses_rating_array
    decorated_district.courses_rating_array
  end

  def courses_academics_rating_array
    decorated_district.courses_academics_rating_array
  end

  def courses_rating_year
    decorated_district.courses_rating_year
  end

  def academic_progress_rating_hash
    decorated_district.academic_progress_rating_hash
  end

  def academic_progress_rating_year
    decorated_district.academic_progress_rating_year
  end

  def historical_student_progress_ratings
    decorated_district.historical_student_growth_ratings
  end

  def equity_ratings_breakdown(breakdown)
    if decorated_district.test_scores_all_rating_hash
      breakdown_results = decorated_district.test_scores_all_rating_hash.select {|bd|
        bd['breakdown'] == breakdown
      }
      if breakdown_results.is_a?(Array) && !breakdown_results.empty?
        breakdown_results.first['district_value_float']
      end
    end
  end

  def ethnicity_data
    flat_test_scores_for_latest_year.select(&:has_ethnicity_tag?)
  end

  def low_income_data
    decorated_district.free_or_reduced_price_lunch_data
  end

  def characteristics_data(*keys)
    decorated_district.characteristics.slice(*keys).each_with_object({}) do |(k, array_of_hashes), hash|
      array_of_hashes = array_of_hashes.select {|h| h.has_key?('source')}
      hash[k] = array_of_hashes if array_of_hashes.present?
    end
  end

  def test_scores
    decorated_district.test_scores
  end

  def flat_test_scores_for_latest_year
    @_flat_test_scores_for_latest_year ||= begin
      array_of_hashes = test_scores.map {|hash| hash.stringify_keys}
      GsdataCaching::GsDataValue.from_array_of_hashes(array_of_hashes).having_most_recent_date
    end
  end

  def recent_test_scores
    flat_test_scores_for_latest_year
      .having_district_value
      .sort_by_cohort_count
      .having_academics
  end

  def recent_test_scores_without_subgroups
    recent_test_scores
      .for_all_students
  end

  def graduation_rate_data
    decorated_district.characteristics['4-year high district graduation rate']
  end

  def characteristics
    decorated_district.characteristics
  end

  def gsdata_data(*keys)
    gs_data(decorated_district.gsdata, *keys)
  end

  def ratings_data(*keys)
    gs_data(decorated_district.ratings, *keys)
  end

  def courses_data(*keys)
    gs_data(decorated_district.courses, *keys)
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
        h['breakdowns'] = h['breakdowns'].gsub('All students except 504 category,', '')
        h['breakdowns'] = h['breakdowns'].gsub(/,All students except 504 category$/, '')
        h['breakdowns'] = h['breakdowns'].gsub('All Students', 'All students')
      end
      h
    end
  end

  def decorated_gsdata_datas(*keys)
    decorated_district.gsdata.slice(*keys).each_with_object({}) do |(data_type, array), accum|
      accum[data_type] =
        array.map do |h|
          GsdataCaching::GsDataValue.from_hash(h).tap {|dv| dv.data_type = data_type}
        end
          .extend(GsdataCaching::GsDataValue::CollectionMethods)
    end
  end


  def decorated_gsdata_data(key)
    Array.wrap(decorated_district.gsdata.slice(key)[key])
      .map do |h|
      GsdataCaching::GsDataValue.from_hash(h).tap {|dv| dv.data_type = key}
    end
      .extend(GsdataCaching::GsDataValue::CollectionMethods)
  end

  def decorated_courses_data(key)
    Array.wrap(decorated_district.courses.slice(key)[key])
      .map do |h|
      GsdataCaching::GsDataValue.from_hash(h).tap {|dv| dv.data_type = key}
    end
      .extend(GsdataCaching::GsDataValue::CollectionMethods)
  end

  def course_enrollment
    decorated_courses_data('Course Enrollment')
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
      GSLogger.error(:summary_rating, error, vars: {district: decorated_district.id, state: decorated_district.state}, message: 'Error creating Time object using source_date_time value for Summary Rating')
      nil
    end
  end

  def format_date(dt_object)
    dt_object.strftime('%b %d, %Y')
  end

  def discipline_flag?
    @_discipline_flag ||= (
    flag_data_value = discipline_attendance_data_values[DISCIPLINE_FLAG]
    flag_data_value.present? && flag_data_value.district_value == '1'
    )
  end

  def attendance_flag?
    @_attendance_flag ||= (
    flag_data_value = discipline_attendance_data_values[ABSENCE_FLAG]
    flag_data_value.present? && flag_data_value.district_value == '1'
    )
  end

  def discipline_attendance_data_values
    @_discipline_attendance_data_values ||= (
    data_hashes = ratings_data(DISCIPLINE_FLAG, ABSENCE_FLAG)
    data_hashes.each_with_object({}) do |(data_type_name, array_of_hashes), output_hash|
      most_recent_all_students = array_of_hashes
                                   .map {|hash| GsdataCaching::GsDataValue.from_hash(hash.merge(data_type: data_type_name))}
                                   .extend(GsdataCaching::GsDataValue::CollectionMethods)
                                   .for_all_students
                                   .most_recent
      output_hash[data_type_name] = most_recent_all_students if most_recent_all_students
    end
    )
  end

  # Returns a hash that includes the percentage and sourcing info
  # {
  #   "breakdowns": "Students with disabilities",
  #   "breakdown_tags": "disability",
  #   "district_value": "11.59",
  #   "source_year": 2014,
  #   "source_name": "Civil Rights Data Collection"
  # }
  def percentage_of_students(breakdown)
    percentages = (
    decorated_district.gsdata.slice('Percentage of Students Enrolled') || {}
    ).fetch('Percentage of Students Enrolled', [])
    percentages.find {|h| h['breakdowns'] == breakdown}
  end

  def esp_responses_data(*keys)
    decorated_district.programs.slice(*keys)
  end

  def subject_scores_by_latest_year(breakdown: 'All', grades: 'All', level_codes: nil, subjects: nil)
    @_subject_scores_by_latest_year ||= (
    subject_hash = test_scores.map do |data_type_id, v|
      level_code_obj = v.seek(breakdown, 'grades', grades, 'level_code')
      if level_code_obj.present?
        level_code_obj.compact.each_with_object({}) do |input_hash, output_hash|
          input_hash[1].each do |subject, year_hash|
            latest_year = year_hash.keys.max_by {|year| year.to_i}
            next if year_hash[latest_year]['score'].nil?
            output_hash[subject] ||= {}
            val = test_scores[data_type_id.to_s][breakdown]
            year_hash[latest_year.to_s]['test_description'] = val['test_description']
            year_hash[latest_year.to_s]['test_label'] = val['test_label']
            year_hash[latest_year.to_s]['test_source'] = val['test_source']
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
    subject_hash.select! {|subject, _| subjects.include?(subject)} if subjects.present?
    subject_hash.inject([]) do |scores_array, (subject, year_hash)|
      scores_array << OpenStruct.new({}.tap do |scores_hash|
        latest_year = year_hash.keys.max_by {|year| year.to_i}
        scores_hash.merge!(year_hash[latest_year.to_s])
        scores_hash['subject'] = subject
        scores_hash['year'] = latest_year
      end)
    end)
  end

  def district_cache_query
    DistrictCacheQuery.for_district(district).tap do |query|
      query.include_cache_keys(district_cache_keys)
    end
  end

  def decorate_district(district)
    query_results = district_cache_query.query
    district_cache_results = DistrictCacheResults.new(DISTRICT_CACHE_KEYS, query_results)
    district_cache_results.decorate_district(district)
  end

  private

  def district=(district)
    raise ArgumentError.new('district must be provided') if district.nil?
    @district = district
  end
end


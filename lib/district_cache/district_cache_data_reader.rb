# frozen_string_literal: true

class DistrictCacheDataReader
  DISTRICT_CACHE_KEYS = %w(feed_test_scores_gsdata test_scores_gsdata feed_test_scores ratings district_schools_summary district_directory metrics feed_metrics crpe)

  attr_reader :district, :district_cache_keys

  def initialize(district, district_cache_keys: DISTRICT_CACHE_KEYS)
    self.district = district
    @district_cache_keys = district_cache_keys
  end

  def decorated_district
    @_decorated_district ||= decorate_district
  end

  def ethnicity_data
    decorated_district.ethnicity_data
  end

  def decorated_metrics_datas(*keys)
    decorated_district.metrics.slice(*keys).each_with_object({}) do |(data_type, array), accum|
      accum[data_type] =
        array.map do |h|
          MetricsCaching::Value.from_hash(h).tap {|dv| dv.data_type = data_type}
        end.extend(MetricsCaching::Value::CollectionMethods)
    end
  end

  # def decorated_gsdata_datas(*keys)
  #   decorated_district.metrics.slice(*keys).each_with_object({}) do |(data_type, array), accum|
  #     accum[data_type] =
  #       array.map do |h|
  #         MetricsCaching::Value.from_hash(h).tap {|dv| dv.data_type = data_type}
  #       end.extend(MetricsCaching::Value::CollectionMethods)
  #   end
  # end

  def decorated_metrics_data(key)
    Array.wrap(decorated_district.metrics.slice(key)[key])
      .map do |h|
      MetricsCaching::Value.from_hash(h).tap {|dv| dv.data_type = key}
    end.extend(MetricsCaching::Value::CollectionMethods)
  end

  def test_scores
    decorated_district.test_scores
  end

  def flat_test_scores_for_latest_year
    @_flat_test_scores_for_latest_year ||= begin
      if test_scores.any? {|test_score| test_score.is_a?(Hash)}
        array_of_hashes = test_scores.map {|hash| hash.stringify_keys}
        GsdataCaching::GsDataValue.from_array_of_hashes(array_of_hashes).having_most_recent_date
      else
        hashes = test_scores.each_with_object([]) do |(data_type, hash_array), array|
          array.concat(
            hash_array.map do |test_scores_hash|
              {
                data_type: data_type,
                description: test_scores_hash['description'],
                source_name: test_scores_hash['source_name'],
                breakdowns: test_scores_hash['breakdowns'],
                breakdown_tags: test_scores_hash['breakdown_tags'],
                source_date_valid: test_scores_hash['source_date_valid'],
                academics: test_scores_hash['academics'],
                grade: test_scores_hash['grade'],
                district_value: test_scores_hash['district_value'],
                district_cohort_count: test_scores_hash['district_cohort_count'],
                state_cohort_count: test_scores_hash['state_cohort_count'],
                state_value: test_scores_hash['state_value'],
              }
            end
          )
        end
        GsdataCaching::GsDataValue.from_array_of_hashes(hashes).having_most_recent_date
      end
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

  def metrics
    decorated_district.metrics
  end

  def distance_learning
    decorated_district.distance_learning
  end

  def gsdata_data(*keys)
    gs_data(decorated_district.metrics, *keys)
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



  def decorated_courses_data(key)
    Array.wrap(decorated_district.courses.slice(key)[key])
      .map do |h|
      GsdataCaching::GsDataValue.from_hash(h).tap {|dv| dv.data_type = key}
    end
      .extend(GsdataCaching::GsDataValue::CollectionMethods)
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
    percentages.find {|h| h['breakdown'] == breakdown}
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
    DistrictCache.for_district(district).include_cache_keys(district_cache_keys)
  end

  def decorate_district
    # district_cache_results = DistrictCacheResults.new(DISTRICT_CACHE_KEYS, district_cache_query)
    district_cache_results = DistrictCacheResults.new(district_cache_keys, district_cache_query)
    district_cache_results.decorate_district(district)
  end

  private

  def district=(district)
    raise ArgumentError.new('district must be provided') if district.nil?
    @district = district
  end
end


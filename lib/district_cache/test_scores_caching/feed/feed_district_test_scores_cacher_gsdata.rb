# frozen_string_literal: true

class TestScoresCaching::Feed::FeedDistrictTestScoresCacherGsdata < TestScoresCaching::DistrictTestScoresCacherGsdata
  CACHE_KEY = 'feed_test_scores_gsdata'
  HASH_NAME_MAP = {
      school_value: 'score',
      source_date_valid: 'year',
      proficiency_band_name: 'proficiency-band-name',
      proficiency_band_id: 'proficiency-band-id',
      data_type_id: 'test-id',
      breakdown_id: 'breakdown-id',
      school_cohort_count: 'number-tested',
      academics: 'subject-name'
  }

  def query_results
    @query_results ||= DataValue.feeds_by_district(district.state, district.id)
  end

  def build_hash_for_cache
    hashes = query_results.map { |r| result_to_hash(r) }
    test_cache_hash = Hash.new { |h, k| h[k] = [] }
    hashes.each_with_object(test_cache_hash) do |result_hash, cache_hash|
      result_hash = result_hash.to_hash
      if valid_result_hash?(result_hash)
        hash_name_changer!(result_hash)
        cache_hash[result_hash[:data_type]] << result_hash.except(*cache_exceptions)
      end
    end
  end

  def hash_name_changer!(hash)
    HASH_NAME_MAP.each do | key, value |
      hash[value.to_sym] = hash.delete(key.to_sym)
    end
  end

  def self.active?
    ENV_GLOBAL['is_feed_builder'].present? && [true, 'true'].include?(ENV_GLOBAL['is_feed_builder'])
  end

  def result_to_hash(result)
    breakdowns = result.breakdown_names
    academics = result.academic_names

    {}.tap do |h|
      h[:data_type] = result.name  #data_type.short_name
      h[:data_type_id] = result.data_type_id #data_type.id
      h[:breakdowns] = breakdowns # if breakdowns
      h[:breakdown_id] = result.breakdown_id_list
      h[:school_value] = result.value  #data_value.value
      h[:source_date_valid] = result.date_valid&.to_date&.year&.to_s  #load.data_valid
      h[:proficiency_band_name] = result.proficiency_band_name
      h[:proficiency_band_id] = result.proficiency_band_id
      h[:school_cohort_count] = result.cohort_count if result.cohort_count #data_value.cohort_count
      h[:academics] = academics # if academics   #data_value.academics.pluck(:name).join(',')
      h[:grade] = result.grade if result.grade  #data_value.grade
    end
  end

  def valid_result_hash?(result_hash)
    result_hash = result_hash.reject { |_,v| v.blank? }
    required_keys = %i(school_value source_date_valid breakdowns)
    missing_keys = required_keys - result_hash.keys
    if missing_keys.count.positive?
      GSLogger.error(
          :state_cache,
          nil,
          message: "#{self.class.name} cache missing required keys",

          vars: {
              school_value: result_hash[:school_value],
              source_date_valid: result_hash[:source_date_valid],
              breakdowns: result_hash[:breakdowns],
          }
      )
    end
    missing_keys.count.zero?
  end

  def cache_exceptions
    %i(data_type percentage narrative label methodology description source_year source_name breakdown_tags flags district_value school_value school_cohort_count)
  end

end
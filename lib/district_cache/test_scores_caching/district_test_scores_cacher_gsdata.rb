# frozen_string_literal: true

class TestScoresCaching::DistrictTestScoresCacherGsdata < TestScoresCaching::DistrictBase

  CACHE_KEY = 'test_scores_gsdata'

  DATA_TYPE_TAGS = 'state_test'

  def query_results
    @query_results ||= Omni::TestDataValue.all_by_district(district.state, district.id)
  end

  def build_hash_for_cache
    hashes = query_results.map { |r| result_to_hash(r) }
    hashes = inject_grade_all(hashes)
    district_cache_hash = Hash.new { |h, k| h[k] = [] }
    hashes.each_with_object(district_cache_hash) do |result_hash, cache_hash|
      result_hash = result_hash.to_hash
      if valid_result_hash?(result_hash)
        cache_hash[result_hash[:data_type]] << result_hash.except(*cache_exceptions)
      end
    end
  end

  def cache_exceptions
    %i(data_type percentage narrative label methodology)
  end

  def self.active?
    true
  end

  private

  def result_to_hash(result)
    breakdowns = result.breakdown_names
    academics = result.academic_names
    state_result = state_result(result)
    {}.tap do |h|
      h[:data_type] = result.name
      h[:breakdowns] = breakdowns
      h[:breakdown_tags] = result.breakdown_tags
# rubocop:disable Style/FormatStringToken
      h[:source_date_valid] = result.date_valid
# rubocop:enable Style/FormatStringToken
      h[:source_name] = result.source_name
      h[:district_value] = result.value
# rubocop:disable Style/SafeNavigation
      h[:state_value] = state_result.value if state_result && state_result.value
      h[:source_name] = result.source
      h[:description] = result.description if result.description
      h[:academics] = academics
      h[:grade] = result.grade if result.grade
      h[:district_cohort_count] = result.cohort_count
      h[:state_cohort_count] = state_result.cohort_count if state_result && state_result.cohort_count
# rubocop:enable Style/SafeNavigation
    end
  end

  def valid_result_hash?(result_hash)
    result_hash = result_hash.reject { |_,v| v.blank? }
    required_keys = %i(data_type source_date_valid source_name district_value)
    missing_keys = required_keys - result_hash.keys
    if missing_keys.count.positive?
      GSLogger.error(
        :school_cache,
        nil,
        message: "#{self.class.name} cache missing required keys",

        vars: { school: district.id,
                state: district.state,
                data_type: result_hash[:data_type],
                breakdowns: result_hash[:breakdowns],
        }
      )
    end
    missing_keys.count.zero?
  end

  def inject_grade_all(hashes)
    DistrictGradeAllCalculator.new(
      GsdataCaching::GsDataValue.from_array_of_hashes(hashes)
    ).inject_grade_all
  end

  def state_results_hash
    @_state_results_hash ||= begin
      state_values = Omni::TestDataValue.all_by_state(district.state)
      state_values.each_with_object({}) do |result, hash|
        state_key = Omni::TestDataValue.datatype_breakdown_year(result)
        hash[state_key] = result
      end
    end
  end

  def state_result(result)
    state_results_hash[Omni::TestDataValue.datatype_breakdown_year(result)]
  end

end

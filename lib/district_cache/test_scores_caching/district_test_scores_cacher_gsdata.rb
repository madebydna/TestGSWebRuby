# frozen_string_literal: true

class TestScoresCaching::DistrictTestScoresCacherGsdata < TestScoresCaching::DistrictBase

  CACHE_KEY = 'test_scores_gsdata'

  DATA_TYPE_TAGS = 'state_test'

  def query_results
    @query_results ||=
      begin
        DataValue.state_and_district_values
          .from(
            DataValue.state_and_district(
              district.state,
              district.id
            ), :data_values
          )
          .where(proficiency_band_id: 1)
          .with_data_types
          .with_data_type_tags(DATA_TYPE_TAGS)
          .with_breakdowns
          .with_breakdown_tags
          .with_academics
          .with_academic_tags
          .with_loads
          .with_sources
          .group('data_values.id')
      end
  end

  def build_hash_for_cache
    hashes = query_results.map { |r| result_to_hash(r) }
    hashes.select {|hash| valid_result_hash? hash }
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
      h[:source_date_valid] = result.date_valid.strftime('%Y%m%d %T')
# rubocop:enable Style/FormatStringToken
      h[:source_name] = result.source_name
      h[:district_value] = result.value
# rubocop:disable Style/SafeNavigation
      h[:state_value] = state_result.value if state_result && state_result.value
      h[:source_name] = result.source_name
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

  def state_results_hash
    @_state_results_hash ||= begin
      state_values = DataValue
                       .find_by_state_and_data_type_tags(district.state, DATA_TYPE_TAGS)
                       .where(proficiency_band_id: 1)

      state_values.each_with_object({}) do |result, hash|
        state_key = result.datatype_breakdown_year
        hash[state_key] = result
      end
    end
  end

  def state_result(result)
    state_results_hash[result.datatype_breakdown_year]
  end

end

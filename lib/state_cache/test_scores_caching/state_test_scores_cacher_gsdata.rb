# frozen_string_literal: trues

class TestScoresCaching::StateTestScoresCacherGsdata < StateCacher
  CACHE_KEY = 'test_scores_gsdata'

  def query_results
    @query_results ||=
      begin
        DataValue.find_by_state_and_data_type_tags_and_proficiency_is_one(state, 'state_test', %w(all) )
      end
  end

  def build_hash_for_cache
    hashes = query_results.map { |r| result_to_hash(r) }.uniq
    hashes = inject_grade_all(hashes)
    state_cache_hash = Hash.new { |h, k| h[k] = [] }
    hashes.each_with_object(state_cache_hash) do |result_hash, cache_hash|
      result_hash = result_hash.to_hash
      if valid_result_hash?(result_hash)
        cache_hash[result_hash[:data_type]] << result_hash.except(*cache_exceptions)
      end
    end
    # hashes.select {|hash| valid_result_hash? hash }
  end

  def cache_exceptions
    %i(data_type percentage narrative label methodology)
  end

  def self.active?
    # ENV_GLOBAL['is_feed_builder'].present? && [true, 'true'].include?(ENV_GLOBAL['is_feed_builder'])
    true
  end

  private

  def result_to_hash(result)
    breakdowns = result.breakdown_names
    academics = result.academic_names
    {}.tap do |h|
      h[:data_type] = result.name
      h[:breakdowns] = breakdowns
      h[:breakdown_tags] = result.breakdown_tags
# rubocop:disable Style/FormatStringToken
      h[:source_date_valid] = result.date_valid
# rubocop:enable Style/FormatStringToken
      h[:source_name] = result.source_name
      h[:state_value] = result.value
      h[:value] = result.value
      h[:description] = result.description if result.description
      h[:academics] = academics
      h[:grade] = result.grade if result.grade
      h[:state_cohort_count] = result.cohort_count
    end
  end

  def valid_result_hash?(result_hash)
    result_hash = result_hash.reject { |_,v| v.blank? }
    required_keys = %i(source_name data_type state_value)
    missing_keys = required_keys - result_hash.keys
    if missing_keys.count.positive?
      GSLogger.error(
        :state_cache,
        nil,
        message: "#{self.class.name} cache missing required keys",

        vars: {
                state: result_hash[:state],
                data_type: result_hash[:data_type],
                breakdowns: result_hash[:breakdowns],
        }
      )
    end
    missing_keys.count.zero?
  end

  def inject_grade_all(hashes)
    StateGradeAllCalculator.new(
      GsdataCaching::GsDataValue.from_array_of_hashes(hashes)
    ).inject_grade_all
  end

  def state_results_hash
    @_state_results_hash ||= begin
      state_values = DataValue
                       .find_by_state_and_data_type_tags_and_proficiency_is_one(district.state, DATA_TYPE_TAGS, %w(all) )
      state_values.each_with_object({}) do |result, hash|
        state_key = DataValue.datatype_breakdown_year(result)
        hash[state_key] = result
      end
    end
  end

  def state_result(result)
    state_results_hash[DataValue.datatype_breakdown_year(result)]
  end
end
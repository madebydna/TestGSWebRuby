# frozen_string_literal: trues

class TestScoresCaching::FeedStateTestScoresCacherGsdata < StateCacher
  CACHE_KEY = 'feed_state_test_scores_gsdata'

  def query_results
    @query_results ||=
      begin
        DataValue.find_by_state_and_data_type_tags(state.state, 'state_test')
          .with_configuration('feeds')
          .map {|obj| TestScoresCaching::DistrictQueryResultDecorator.new(district.state, obj)}
      end
  end

  def build_hash_for_cache
    hashes = query_results.map { |r| result_to_hash(r) }.uniq
    school_cache_hash = Hash.new { |h, k| h[k] = [] }
    hashes.each_with_object(school_cache_hash) do |result_hash, cache_hash|
      result_hash = result_hash.to_hash
      if valid_result_hash?(result_hash)
        cache_hash[result_hash[:data_type]] << result_hash.except(:data_type, :percentage, :narrative, :label, :methodology)
      end
    end
  end

  def self.active?
    ENV_GLOBAL['is_feed_builder'].present? && [true, 'true'].include?(ENV_GLOBAL['is_feed_builder'])
  end

  private
  
  def result_to_hash(result)
    breakdowns = result.breakdown_names
    breakdown_tags = result.breakdown_tags
    academics = result.academic_names
    academic_tags = result.academic_tags
    # academic_types = result.academic_types
    # display_range = display_range(result)
    state_result = state_result(result)
    district_value = district_value(result)
    {}.tap do |h|
      h[:data_type] = result.name  #data_type.short_name
      h[:breakdowns] = breakdowns # if breakdowns
      h[:breakdown_tags] = breakdown_tags # if breakdown_tags
# rubocop:disable Style/FormatStringToken
      h[:source_date_valid] = result.date_valid.strftime('%Y%m%d %T')  #source.data_valid
# rubocop:enable Style/FormatStringToken
# rubocop:disable Style/SafeNavigation
      h[:state_value] = state_result.value if state_result && state_result.value #data_type.value

      h[:district_value] = district_value if district_value   #data_type.value
      h[:source_name] = result.source_name    #source.name
      h[:description] = result.description if result.description    #source.description
      h[:school_cohort_count] = result.cohort_count if result.cohort_count #data_value.cohort_count
      h[:academics] = academics # if academics   #data_value.academics.pluck(:name).join(',')
      h[:academic_tags] = academic_tags # if academic_tags  #academic_tags.tag...comma separated string for all records associated with data value
      h[:grade] = result.grade if result.grade  #data_value.grade
      h[:state_cohort_count] = state_result.cohort_count if state_result && state_result.cohort_count  #data_value.cohort_count
# rubocop:enable Style/SafeNavigation
    end
  end

  def valid_result_hash?(result_hash)
    result_hash = result_hash.reject { |_,v| v.blank? }
    required_keys = %i(source_name)
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
end
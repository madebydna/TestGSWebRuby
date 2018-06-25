# frozen_string_literal: true

class TestScoresCaching::DistrictTestScoresCacherGsdata < TestScoresCaching::DistrictBase

  CACHE_KEY = 'test_scores_gsdata'

  def query_results
    @query_results ||=
      begin
        DataValue.find_by_district_and_data_type_tags(district.state, district.id, 'state_test')
          .with_configuration('feeds')
      end
  end

  def build_hash_for_cache
    hashes = query_results.map { |r| result_to_hash(r) }
    hashes.select {|hash| valid_result_hash? hash }
  end

  def self.active?
        ENV_GLOBAL['is_feed_builder'].present? && [true, 'true'].include?(ENV_GLOBAL['is_feed_builder'])
  end

  private

  def result_to_hash(result)
    breakdowns = result.breakdown_names
    academics = result.academic_names
    {}.tap do |h|
      h[:data_type] = result.name
      h[:breakdowns] = breakdowns
# rubocop:disable Style/FormatStringToken
      h[:source_date_valid] = result.date_valid.strftime('%Y%m%d %T')  #source.data_valid
      h[:source_name] = result.source_name
# rubocop:enable Style/FormatStringToken
      h[:value] = result.value
      h[:source_name] = result.source_name
      h[:description] = result.description if result.description
      h[:academics] = academics
      h[:grade] = result.grade if result.grade  #data_value.grade
      h[:cohort_count] = result.cohort_count
    end
  end

  def valid_result_hash?(result_hash)
    result_hash = result_hash.reject { |_,v| v.blank? }
    required_keys = %i(data_type source_date_valid source_name value)
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
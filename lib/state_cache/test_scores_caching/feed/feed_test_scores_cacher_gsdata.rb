# frozen_string_literal: true

class TestScoresCaching::Feed::FeedTestScoresCacherGsdata < TestScoresCaching::TestScoresCacherGsdata
  CACHE_KEY = 'feed_test_scores_gsdata'


  def query_results
    @query_results ||=
      begin
        DataValue
          .find_by_school_and_data_types_with_proficiency_band_name(school, data_type_ids, data_type_tags, 'feeds')
          .with_configuration('feeds')
          .where(proficiency_band_id: 1)
      end
  end

  def school_results
    @_school_results ||= query_results.extend(TestScoreCalculations)
  end

  def self.active?
    ENV_GLOBAL['is_feed_builder'].present? && [true, 'true'].include?(ENV_GLOBAL['is_feed_builder'])
  end

  def result_to_hash(result)
    # require 'pry';binding.pry;
    breakdowns = result.breakdown_names
    breakdown_tags = result.breakdown_tags
    academics = result.academic_names
    academic_tags = result.academic_tags
    state_result = state_result(result)
    # district_value = district_value(result)

    {}.tap do |h|
      h[:data_type] = result.name  #data_type.short_name
      h[:breakdowns] = breakdowns # if breakdowns
      h[:breakdown_tags] = breakdown_tags # if breakdown_tags
      h[:school_value] = result.value  #data_value.value

      h[:source_date_valid] = result.source_date_valid.strftime('%Y')  #source.data_valid
      h[:proficiency_band_name] = result.proficiency_band_name
# rubocop:disable Style/SafeNavigation
      h[:state_value] = state_result.value if state_result && state_result.value #data_type.value
      h[:district_value] = district_value if district_value   #data_type.value
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
    required_keys = %i(state_value source_date_valid data_type)
    missing_keys = required_keys - result_hash.keys
    if missing_keys.count.positive?
      GSLogger.error(
          :school_cache,
          nil,
          message: "#{self.class.name} cache missing required keys",

          vars: {
                  state: school.state,
                  data_type: result_hash[:data_type],
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
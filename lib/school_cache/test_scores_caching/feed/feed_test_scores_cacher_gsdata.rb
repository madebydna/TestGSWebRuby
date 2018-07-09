# frozen_string_literal: true

class TestScoresCaching::Feed::FeedTestScoresCacherGsdata < TestScoresCaching::TestScoresCacherGsdata
  CACHE_KEY = 'feed_test_scores_gsdata'

  def query_results
    @query_results ||=
      begin
         DataValue
          .find_by_school_and_data_type_tags(school, data_type_tags, 'feeds')
          .with_configuration('feeds')
      end
  end

  def self.active?
    ENV_GLOBAL['is_feed_builder'].present? && [true, 'true'].include?(ENV_GLOBAL['is_feed_builder'])
  end

  def result_to_hash(result)
    breakdowns = result.breakdown_names
    breakdown_tags = result.breakdown_tags
    academics = result.academic_names
    academic_tags = result.academic_tags
    state_result = state_result(result)
    district_value = district_value(result)

    {}.tap do |h|
      h[:data_type] = result.name  #data_type.short_name
      h[:breakdowns] = breakdowns # if breakdowns
      h[:breakdown_tags] = breakdown_tags # if breakdown_tags
      h[:school_value] = result.value  #data_value.value

      h[:year] = result.date_valid.strftime('%Y')  #source.data_valid

# rubocop:disable Style/SafeNavigation
      h[:state_value] = state_result.value if state_result && state_result.value #data_type.value
      # h[:district_value] = district_value if district_value   #data_type.value
      h[:school_cohort_count] = result.cohort_count if result.cohort_count #data_value.cohort_count
      h[:academics] = academics # if academics   #data_value.academics.pluck(:name).join(',')
      h[:academic_tags] = academic_tags # if academic_tags  #academic_tags.tag...comma separated string for all records associated with data value
      h[:grade] = result.grade if result.grade  #data_value.grade
      h[:state_cohort_count] = state_result.cohort_count if state_result && state_result.cohort_count  #data_value.cohort_count
# rubocop:enable Style/SafeNavigation
    end
  end
end
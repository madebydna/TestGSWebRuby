# frozen_string_literal: true

class StateCache::FeedDistrictTestScoresCacherGsdata < TestScoresCaching::TestScoresCacherGsdata
  CACHE_KEY = 'feed_district_test_scores_gsdata'

  def query_results
    @query_results ||=
      begin
        DataValue
          .find_by_district_and_data_type_tags(school.state, school.district_id, data_type_tags)
          .with_configuration('feeds')
          .reject {|result| result.school_id.present}
          .map {|obj| TestScoresCaching::QueryResultDecorator.new(school.state, obj)}
      end
  end

  def self.active?
    ENV_GLOBAL['is_feed_builder'].present? && [true, 'true'].include?(ENV_GLOBAL['is_feed_builder'])
  end
end
# frozen_string_literal: true

class StateCache::FeedStateTestScoresCacherGsdata < TestScoresCaching::TestScoresCacherGsdata
  CACHE_KEY = 'feed_state_test_scores_gsdata'

  def query_results
    @query_results ||=
      begin
        DataValue
          .find_by_state_and_data_type_tags(school, ['state_test'])
          .with_configuration('feeds')
          .reject {|result| result.district_id.present || result.school_id.present}
          .map {|obj| TestScoresCaching::QueryResultDecorator.new(school.state, obj)}
      end
  end

  def self.active?
    ENV_GLOBAL['is_feed_builder'].present? && [true, 'true'].include?(ENV_GLOBAL['is_feed_builder'])
  end
end
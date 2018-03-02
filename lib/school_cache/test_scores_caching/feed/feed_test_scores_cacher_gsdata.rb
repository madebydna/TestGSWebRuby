# frozen_string_literal: true

class TestScoresCaching::Feed::FeedTestScoresCacherGsdata < TestScoresCaching::TestScoresCacherGsdata
  CACHE_KEY = 'feed_test_scores_gsdata'

  def query_results
    @query_results ||=
      begin
         DataValue
          .find_by_school_and_data_type_tags(school, data_type_tags, 'feeds')
          .with_configuration('feeds')
          .reject {|result| result.district_id.blank? || result.data_type_id.blank?}
          .map {|obj| TestScoresCaching::QueryResultDecorator.new(school.state, obj)}
      end
  end

  def self.active?
    ENV_GLOBAL['is_feed_builder'].present? && [true, 'true'].include?(ENV_GLOBAL['is_feed_builder'])
  end
end
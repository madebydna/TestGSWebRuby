class FeedTestScoresCacher < TestScoresCaching::BreakdownsCacher
  CACHE_KEY = 'feed_test_scores'

  def query_results
    @query_results ||= (
      results =
          (
          TestDataSet.fetch_feed_test_scores(school, breakdown_id: 1) +
              TestDataSet.fetch_feed_test_scores(school, grade: 'All')
          ).select do |result|
            data_type_id = result.data_type_id
            # skip this if no corresponding test data type
            test_data_types && test_data_types[data_type_id].present?
          end
      results.map { |obj| TestScoresCaching::QueryResultDecorator.new(school.state, obj) }
    )
  end

  def self.active?
    ENV_GLOBAL['is_feed_builder'].present? && [true, 'true'].include?(ENV_GLOBAL['is_feed_builder'])
  end
end
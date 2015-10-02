class PerformanceCaching::PerformanceCacher < TestScoresCaching::Base
  include CacheFormat

  CACHE_KEY = 'performance'

  def query_results
    @query_results ||= begin
      TestDataSet.fetch_performance_results(school, grade: 'All').map do |obj|
        PerformanceCaching::QueryResultDecorator.new(school.state, obj)
      end
    end
    @all_results = @query_results
  end
end

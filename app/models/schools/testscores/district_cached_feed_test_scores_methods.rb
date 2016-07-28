module DistrictCachedFeedTestScoresMethods
  def feed_test_scores
    cache_data['feed_test_scores'] || {}
  end

end
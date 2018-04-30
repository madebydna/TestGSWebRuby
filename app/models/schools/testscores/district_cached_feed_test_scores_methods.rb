module DistrictCachedFeedTestScoresMethods
  def feed_test_scores
    cache_data['feed_district_test_scores_gsdata'] || {}
  end

end
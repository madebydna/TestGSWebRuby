module CachedTestScoresMethods
  def test_scores
    cache_data['test_scores'] || {}
  end

end
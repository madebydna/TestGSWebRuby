module StateCachedTestScoresMethods

  def test_scores
    cache_data['test_scores_gsdata'] || []
  end

end

class TestScoresDataReader < SchoolProfileDataReader

  def data_for_category(_)
    TestScoreResults.new.fetch_test_scores school
  end

end
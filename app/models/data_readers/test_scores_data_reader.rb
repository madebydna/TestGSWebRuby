class TestScoresDataReader < SchoolProfileDataReader

  def data
    @data ||= TestScoreResults.new.fetch_test_scores school
  end

end
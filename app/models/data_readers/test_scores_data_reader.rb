class TestScoresDataReader < SchoolProfileDataReader

  def data
    @data ||= TestScoreResults.new.fetch_test_scores school
    require 'pry-debugger'
    binding.pry
    @data
  end

end
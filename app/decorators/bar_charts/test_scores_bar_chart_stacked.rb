class BarCharts::TestScoresBarChartStacked < BarCharts::TestScoresBarChart

  def create_bar(hash)
    BarCharts::TestScoresBarStacked.new(hash)
  end

end
class BarCharts::TestScoresBarChartStacked < BarCharts::TestScoresBarChart

  def bar_chart_array
    array_for_all_bars = []
    array_for_all_bars += @test_scores_hash.map do |(key, value)|
      bar_hash = value.clone
      bar_hash['year'] = key
      bar = create_bar bar_hash
      bar.array_for_bar
    end
  end

  def create_bar(hash)
    BarCharts::TestScoresBarStacked.new(hash)
  end

end
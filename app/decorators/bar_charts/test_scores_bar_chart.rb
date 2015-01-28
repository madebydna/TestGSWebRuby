class BarCharts::TestScoresBarChart

  attr_accessor :test_scores_hash

  def initialize(test_scores_hash)
    @test_scores_hash = test_scores_hash
  end

  def create_bar(hash)
    BarCharts::TestScoresBar.new(hash)
  end

  def contains_empty_bar?
    year_to_bars_hash.values.find { |element| element.is_a?(Array) && element.size <= 1 }
  end

  def script_tag(bar_chart_div_id)
    if bar_chart_array.present?
      '<script>' +
      "GS.visualchart.drawBarChartTestScores(#{bar_chart_array.to_s}, '#{bar_chart_div_id}', 'testscores');" +
      '</script>'
    end
  end

  def bar_chart_array
    @bar_chart_array ||= (
      year_to_bars_hash = self.year_to_bars_hash
      array_for_all_bars = @test_scores_hash.map { |year, value| year_to_bars_hash[year] }
    )
  end

  def year_to_bars_hash
    @test_scores_hash.each_with_object({}) do |(year, bar_hash), year_to_array_hash|
      bar_hash = bar_hash.clone
      bar_hash['year'] = year
      bar = create_bar(bar_hash)
      year_to_array_hash[year] = bar.array_for_bar
    end
  end

end





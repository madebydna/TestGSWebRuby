class BarCharts::TestScoresBarChartStacked < BarCharts::TestScoresBarChart

  def create_bar(hash)
    BarCharts::TestScoresBarStacked.new(hash)
  end

  def script_tag(bar_chart_div_id)
    if bar_chart_array.present?
      '<script>' +
      "GS.visualchart.drawBarChartTestScoresStacked(#{bar_chart_array.to_s}, '#{bar_chart_div_id}', 'testscores');" +
      '</script>'
    end
  end

end
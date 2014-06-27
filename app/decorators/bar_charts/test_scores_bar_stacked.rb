class BarCharts::TestScoresBarStacked < BarCharts::TestScoresBar

  def array_for_single_bar
    bv = self.bar_value(test_scores_bar_hash['score'])
    bar_value_annotation = bv.to_s + '%'

    # Tool tips and annotation columns should be strings.
    student_count = test_scores_bar_hash['school_number_tested']
    student_proficiency = test_scores_bar_hash['score']
    state_average = test_scores_bar_hash['state_avg']
    sa_annotation = state_average.to_s + '%'

    tool_tip = bar_chart_tooltip_html(student_count, student_proficiency, state_average)

    [bv, bar_value_annotation, tool_tip, state_average, sa_annotation, tool_tip]
  end

end
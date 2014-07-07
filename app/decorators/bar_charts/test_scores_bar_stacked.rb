class BarCharts::TestScoresBarStacked < BarCharts::TestScoresBar

  def array_for_single_bar
    bv = self.bar_value(test_scores_bar_hash['proficient_score'])
    bar_value_annotation = bv.to_s + '%'

    # Tool tips and annotation columns should be strings.
    student_count = test_scores_bar_hash['school_number_tested']
    total_score = test_scores_bar_hash['score']
    advanced_score = test_scores_bar_hash['advanced_score']
    state_average = test_scores_bar_hash['state_avg']
    as_annotation = advanced_score.to_s + '%'

    tool_tip = bar_chart_tooltip_html(student_count, total_score, state_average)

    [bv, bar_value_annotation, tool_tip, advanced_score, as_annotation, tool_tip]
  end

end
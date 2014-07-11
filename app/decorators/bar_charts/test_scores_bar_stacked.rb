class BarCharts::TestScoresBarStacked < BarCharts::TestScoresBar

  def array_for_single_bar
    raw_proficient = test_scores_bar_hash['proficient_score']
    raw_advanced = test_scores_bar_hash['advanced_score']

    proficient_bar_value = self.bar_value(raw_proficient)
    proficient_bar_annotation = raw_proficient ? proficient_bar_value.to_s + '%' : ''
    advanced_bar_value = self.bar_value(raw_advanced)
    advanced_bar_annotation = raw_advanced ? advanced_bar_value.to_s + '%' : ''

    # Tool tips and annotation columns should be strings.
    student_count = test_scores_bar_hash['school_number_tested']
    total_score = test_scores_bar_hash['score']
    state_average = test_scores_bar_hash['state_avg']
    tool_tip = bar_chart_tooltip_html(student_count, total_score, state_average)

    if proficient_bar_value > 0 || advanced_bar_value > 0
      [
        proficient_bar_value,
        proficient_bar_annotation,
        tool_tip,
        advanced_bar_value,
        advanced_bar_annotation,
        tool_tip
      ]
    else
      []
    end
  end

end
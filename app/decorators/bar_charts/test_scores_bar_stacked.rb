class BarCharts::TestScoresBarStacked < BarCharts::TestScoresBar

  def array_for_bar
    array = [test_scores_bar_hash['year'].to_s]
    array += array_for_single_bar
  end

  def array_for_single_bar
    bv = self.bar_value(test_scores_bar_hash['score'])
    bar_value_annotation = bv.to_s + '%'
    # display_value = self.display_value(test_scores_bar_hash['score'])
    # bar_value = self.bar_value(test_scores_bar_hash['stat'])
    # display_value = self.display_value(test_scores_bar_hash)

    # Tool tips and annotation columns should be strings.
    # annotation = value.present? ? "#{display_value}%" : ''
    student_count = test_scores_bar_hash['school_number_tested']
    student_proficiency = 77
    state_average = test_scores_bar_hash['state_avg']
    sa_annotation = state_average.to_s + '%'
    tool_tip = bar_chart_tooltip_html(student_count, student_proficiency, state_average)

    [bv, bar_value_annotation, tool_tip, state_average, sa_annotation, tool_tip]
  end



  def bar_chart_tooltip_html(student_count, student_proficiency, state_average)
    #new tooltip content - first count then % and %
    # ## Students tested
    # ## Students are proficient or better
    # ## State average
    tooltip = ''
    if student_count.present? || student_proficiency.present? || state_average.present?
      tooltip = '<table style="line-height:1.2" cellpadding=5>'

      if student_count.present?
        tooltip << '<tr><td valign="top"><b>' + student_count.to_s + '</b></td><td>Students tested</td></tr>'
      end
      if student_proficiency.present?
        tooltip << '<tr><td valign="top"><b>' +student_proficiency.to_s+'%</b></td><td>Students are proficient or better</td></tr>'
      end
      if state_average.present?
        tooltip << '<tr><td valign="top"><b>' +state_average.to_s+'%</b></td><td>State average</td></tr>'
      end
      tooltip << '</table>'
    end
    tooltip
  end
end
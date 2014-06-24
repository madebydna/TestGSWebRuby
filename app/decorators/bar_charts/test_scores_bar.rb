class BarCharts::TestScoresBar
  attr_accessor :test_scores_bar_hash

  def initialize(test_scores_bar_hash)
    @test_scores_bar_hash = test_scores_bar_hash
  end

  def array_for_bar
    array = [test_scores_bar_hash['year'].to_s]
    array += array_for_single_bar
  end

  def bar_value(value)
    # Google bar chart requires values to be numerical. They will default to 0
    value.to_s.gsub(/<|=|>/,'').to_f.round
  end

  def display_value(value)
    string_value = value.to_s
    dv = value.to_f.round
    if string_value.match /<|=|>/
      dv = value
    end
    dv
  end

  def array_for_single_bar
    value = test_scores_bar_hash['score']
    bar_value = self.bar_value(value)
    display_value = self.display_value(value)

    # Tool tips and annotation columns should be strings.
    student_count = test_scores_bar_hash['school_number_tested']
    student_proficiency = test_scores_bar_hash['score']
    state_average = test_scores_bar_hash['state_avg']

    # Tool tips and annotation columns should be strings.
    annotation = value.present? ? "#{display_value}%" : ''
    tool_tip = bar_chart_tooltip_html(student_count, student_proficiency, state_average)

    [bar_value, annotation, tool_tip]
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
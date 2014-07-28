class TestScoresDecorator < Draper::Decorator
  decorates :hash

  def grades(test, breakdown = :All)
    hash[test].seek(breakdown, :grades)
  end

  def breakdowns(test)
    hash.fetch(test, {}).keys
  end

  def tabs_for_test(test)
    buttons = ''
    grades = self.grades(test)
    return if grades.blank?

    buttons << h.content_tag(:div, class: "btn-group js_grades_div js_bootstrapExtButtonSelect") do
      grades.each_with_index do |(grade, grade_hash), index_grade|
        h.concat(h.button_tag(
          id: test_button_dom_id(test, :All, grade),
          class: "btn btn-default js_test_scores_grades#{index_grade == 0 ? ' active' : ''}"
        ) do
          grade_hash[:label].html_safe
        end)
      end
    end

    breakdowns = self.breakdowns(test).reject { |breakdown| breakdown == :All }
    if breakdowns.present?
      buttons << h.content_tag(:span, class: 'js_test_groups dropdown pll') do
        h.concat(
          h.button_tag('groups', class: 'btn btn-group btn-default', 'data-toggle' => 'dropdown') do
            'Groups <b class="caret"></b>'.html_safe
          end
        )
        h.concat(h.content_tag(:ul, class: 'dropdown-menu mll', style: '') do
          breakdowns.each do |breakdown|
            h.concat(
              h.content_tag(
                :li,
                class: 'js_test_scores_grades',
                id: test_button_dom_id(test, breakdown, :All)
              ) { h.content_tag(:a) { breakdown.to_s.html_safe } }
            )
          end
        end)
      end
    end
    buttons
  end

  def bar_chart(hash)
    bar_chart = nil
    # Only show stacked with proficiency for Delaware
    if state.upcase == "DE"
      bar_chart = BarCharts::TestScoresBarChartStacked.new(hash)
      if bar_chart.contains_empty_bar?
        bar_chart = BarCharts::TestScoresBarChart.new(hash)
      end
    else
      bar_chart = BarCharts::TestScoresBarChart.new(hash)
    end
    bar_chart
  end

  def self.bar_chart_div_id(test, breakdown, grade, subject)
    test = test.to_s.gsub(/\s/,'')
    breakdown = breakdown.to_s.gsub(/\s/, '')
    subject = subject.to_s.gsub(/\s/,'')
    bar_chart_div_id = "js_bar_chart_div_#{test}_#{breakdown},#{grade}_#{subject}"
  end

  def test_container_dom_id(test, breakdown, grade)
    test_button_dom_id(test, breakdown, grade) + '_scores'
  end

  def test_button_dom_id(test, breakdown, grade)
    test = test.to_s.gsub(/\s/,'')
    breakdown = breakdown.to_s.gsub(/\s/, '')
    "js_#{test}_#{breakdown}_#{grade}"
  end

  def render_bar_charts(test)
    return if grades(test).blank?
    content = ''

    if breakdowns(test).any?
      # this loop will include the nil/default breakdown
      breakdowns(test).each do |breakdown|
        content << render_bar_charts_for_breakdown(test, breakdown)
      end
    else
      content << render_bar_charts_for_breakdown(test, :All)
    end
    content
  end

  def render_bar_charts_for_breakdown(test, breakdown)
    content = ''
    grades(test, breakdown).each_with_index do |(grade,grade_hash), index_grade|
      css_class = "js_#{test}_grades"
      css_class << ' dn' unless index_grade == 0 && breakdown == :All
      content << h.content_tag(:div, id: test_container_dom_id(test, breakdown, grade), class: css_class) do
        div_content = ''
        grade_hash[:level_code].each do |levelcode,value|
          value.each_with_index do |(subject,value), index_subject|
            div_id = TestScoresDecorator.bar_chart_div_id(test, breakdown, grade, subject)
            h.content_for(:head) do
              h.raw bar_chart(value).script_tag(div_id)
            end
            div_content << h.content_tag(:h4, class: (index_subject == 0 ? 'ptl' : '')) do
              subject.to_s.gs_capitalize_first
            end
            # TODO change this to test id
            div_content << h.content_tag(:div, id: div_id, class: 'notranslate ma') do
              ''
            end
          end
        end
        div_content.html_safe
      end
    end
    content
  end

  def state
    context[:state]
  end

end
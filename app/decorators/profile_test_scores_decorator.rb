class ProfileTestScoresDecorator < Draper::Decorator
  decorates :hash

  def grades(test, breakdown = :All)
    hash[test].seek(breakdown, :grades)
  end

  def breakdowns(test)
    hash.fetch(test, {}).keys
  end

  def description(test)
    test[:All][:test_description]
  end

  def source(test)
    test[:All][:test_source]
  end

  def label(grade_hash)
    cached_label = grade_hash[:label]
    grade_number_regex_matches = cached_label.match /GRADE ([0-9]+)/
    if grade_number_regex_matches.nil?
      I18n.db_t(cached_label, scope: 'decorators.test_scores_decorator', default: cached_label)
    else
      grade_number = grade_number_regex_matches[1]
      I18n.t('decorators.test_scores_decorator.grade', grade_number: grade_number).upcase
    end
  end

  def tabs_for_test(test)
    buttons = ''
    grades = self.grades(test)
    return if grades.blank?

    buttons << h.content_tag(:div, class: "fl btn-group js_grades_div js_bootstrapExtButtonSelect") do
      grades.each_with_index do |(grade, grade_hash), index_grade|
        h.concat(h.button_tag(
          id: test_button_dom_id(test, :All, grade),
          class: "btn btn-default js_test_scores_grades#{index_grade.zero? ? ' active' : ''}"
        ) do
          label(grade_hash)
        end)
      end
    end

    breakdowns = self.breakdowns(test).reject { |breakdown| breakdown == :All }
    if breakdowns.present?
      buttons << h.content_tag(:div, class: 'js_test_groups dropdown fl pll') do
        h.concat(
          h.button_tag('groups', class: 'btn btn-default', 'data-toggle' => 'dropdown') do
            "#{h.t('decorators.test_scores_decorator.by_group')} <b class=\"caret\"></b>".html_safe
          end
        )
        h.concat(h.content_tag(:ul, class: 'dropdown-menu mll', style: '') do
          breakdowns.each do |breakdown|
            h.concat(
              h.content_tag(
                :li,
                class: 'js_test_scores_grades',
                id: test_button_dom_id(test, breakdown, :All)
              ) { h.content_tag(:a) { I18n.db_t(breakdown.to_s, default: breakdown.to_s)} }
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
    test = test.to_s.gsub(/[^0-9A-Za-z]/,'')
    breakdown = breakdown.to_s.gsub(/[^0-9A-Za-z]/, '')
    subject = subject.to_s.gsub(/[^0-9A-Za-z]/,'')
    bar_chart_div_id = "js_bar_chart_div_#{test}_#{breakdown}_#{grade}_#{subject}"
  end

  def test_container_dom_id(test, breakdown, grade)
    test_button_dom_id(test, breakdown, grade) + '_scores'
  end

  def test_button_dom_id(test, breakdown, grade)
    test = test.to_s.gsub(/[^0-9A-Za-z]/,'')
    breakdown = breakdown.to_s.gsub(/[^0-9A-Za-z]/, '')
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
      css_class << ' dn' unless index_grade.zero? && breakdown == :All
      content << h.content_tag(:div, id: test_container_dom_id(test, breakdown, grade), class: css_class) do
        div_content = ''
        grade_hash[:level_code].each do |levelcode,value|
          value.each_with_index do |(subject,v), index_subject|
            div_id = ProfileTestScoresDecorator.bar_chart_div_id(test, breakdown, grade, subject)
            h.content_for(:head) do
              h.raw bar_chart(v).script_tag(div_id)
            end
            div_content << h.content_tag(:h4, class: (index_subject.zero? ? 'ptl' : '')) do
              I18n.db_t(subject.to_s.gsub('.', ''), default: subject.to_s).gs_capitalize_first
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

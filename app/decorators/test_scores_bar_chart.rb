class TestScoresBarChart
  attr_accessor :test_scores_hash

  def initialize(test_scores_hash)
    @test_scores_hash = test_scores_hash
  end

  def bar_chart_array_header
    [
      'year',
      'This school',
      'School Annotation',
      'School tool tip',
      'State average',
      'State Annotation',
      'State tool tip'
    ]
  end

  def array_for_single_bar(value, tool_tip_prefix)
    string_value = value.to_s
    # Google bar chart requires values to be numerical. They will default to 0
    bar_value = string_value.gsub(/<|=|>/,'').to_f.round

    if string_value.match /<|=|>/
      display_value = value
    else
      display_value = value.to_f.round
    end

    # Tool tips and annotation columns should be strings.
    annotation = string_value.present? ? "#{display_value}%" : ''
    tool_tip = string_value.present? ? "#{tool_tip_prefix} #{display_value}%" : ''

    [bar_value, annotation, tool_tip]
  end

  def bar_chart_array
    array_for_all_bars = []
    array_for_all_bars << bar_chart_array_header
    array_for_all_bars += @test_scores_hash.map do |(key, value)|
      array = [key.to_s]
      array += array_for_single_bar(value['score'], 'This school:')
      array += array_for_single_bar(value['state_avg'], 'State average:')
    end
  end
  
end
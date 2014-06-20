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
    int_value = string_value.gsub(/<|=|>|\./,'').to_i
    # Tool tips and annotation columns should be strings.
    annotation = string_value.present? ? "#{int_value}%" : ''
    tool_tip = string_value.present? ? "#{tool_tip_prefix} #{string_value}%" : ''

    [int_value, annotation, tool_tip]
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
class BarCharts::TestScoresBar
  attr_accessor :test_scores_bar_hash

  def initialize(test_scores_bar_hash)
    @test_scores_bar_hash = test_scores_bar_hash
  end

  def array_for_bar
    array = [test_scores_bar_hash['year'].to_s]
    array += array_for_single_bar(test_scores_bar_hash['score'], 'This school:')
    array += array_for_single_bar(test_scores_bar_hash['state_avg'], 'State average:')
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

  def array_for_single_bar(value, tool_tip_prefix)
    bar_value = self.bar_value(value)
    display_value = self.display_value(value)

    # Tool tips and annotation columns should be strings.
    annotation = value.present? ? "#{display_value}%" : ''
    tool_tip = value.present? ? "#{tool_tip_prefix} #{display_value}%" : ''

    [bar_value, annotation, tool_tip]
  end

end
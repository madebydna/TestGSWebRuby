class BarChartGroup
  include ActiveRecord::Callbacks

  # Class that holds a collection of graphs related by subject or breakdown.
  # Header and array of chart data.

  attr_accessor :bar_charts, :data, :config, :title

  def initialize(data, title = nil, config = {})
    # Title is optional because for single chart groups, there is no group title
    self.data = data
    self.config = config
    self.title = title

    create_bar_charts!
  end

  private

  def create_bar_charts!
    self.bar_charts = data.map do |data_point|
      bar_chart = BarChart.new(
        {
          label: label_for(data_point, config),
          value: data_point[:school_value],
          comparison_value: data_point[:state_average],
          performance_level: data_point[:performance_level],
        }
      )
      bar_chart.display? ? bar_chart : nil
    end.compact.sort_by { |chart| chart.label }.reverse
    # The above 'sort by desc' appears to be the most performant way:
    # http://stackoverflow.com/questions/2642182/sorting-an-array-in-descending-order-in-ruby
  end

  def label_for(data_point, config)
    config[:label_field] ? data_point[config[:label_field]] : nil
  end
end

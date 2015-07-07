class BarChartGroup
  include ActiveRecord::Callbacks

  # Class that holds a collection of graphs related by subject or breakdown.
  # Header and array of chart data.

  attr_accessor :bar_charts, :data, :options, :title

  def initialize(data, title = nil, options = {})
    # Title is optional because for single chart groups, there is no group title
    # TODO This needs some config about which field to pass as chart title
    self.data = data
    self.options = options
    self.title = title

    create_bar_charts!
  end

  private

  def create_bar_charts!
    self.bar_charts = data.map do |data_point|
      BarChart.new(
        {
          label: data_point[options[:label_field]],
          value: data_point[:school_value],
          comparison_value: data_point[:state_average],
          color: data_point[:color],
        }
      )
    end
  end
end

class BarChart
  # Class that holds a collection of graphs related by subject or breakdown.
  # Header and array of chart data.

  attr_accessor :bar_chart_bars, :data, :config, :title

  def initialize(data, title = nil, config = {})
    # Title is optional because for single chart groups, there is no group title
    self.data = data
    self.config = config
    self.title = title

    create_bar_chart_bars!
  end

  private

  def create_bar_chart_bars!
    self.bar_chart_bars = sorted_data.map do |data_point|
      bar_chart_bar = BarChartBar.new(
        {
          label: label_for(data_point, config),
          value: data_point[:school_value],
          comparison_value: data_point[:state_average],
          performance_level: data_point[:performance_level],
          subtext: data_point[:subtext]
        }
      )
      bar_chart_bar.display? ? bar_chart_bar : nil
    end.compact
  end

  def sorted_data
    callbacks = config[:sort_groups_by]

    [*callbacks].inject(data) do |gd, c|
      send("sort_by_#{c}".to_sym, gd)
    end
  end

  def sort_by_desc(group_data)
    key = config[:create_sort_by]
    return group_data unless key.present?

    group_data.sort_by{|d| d[key].nil? ? -1 : d[key].to_f}.reverse!
  end

  def sort_by_all_students(group_data)
    i = group_data.find_index { |d| d[:breakdown].downcase == 'all students' }
    i.present? ? group_data.insert(0, group_data.delete_at(i)) : group_data
  end

  def label_for(data_point, config)
    config[:label_charts_with] ? data_point[config[:label_charts_with]] : nil
  end
end

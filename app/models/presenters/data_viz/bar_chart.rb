class BarChart
  # Class that holds a collection of graphs related by subject or breakdown.
  # Header and array of chart data.

  attr_accessor :bar_chart_bars, :data, :config, :title, :sort_by_config

  DEFAULT_CALLBACKS = [ 'sort_by' ]

  def initialize(data, title = nil, config = {})
    # Title is optional because for single chart groups, there is no group title
    self.data = data
    self.config = config
    self.title = title
    self.sort_by_config = config[:sort_by]

    create_bar_chart_bars!
  end

  private

  def create_bar_chart_bars!
    run_config_callbacks!

    self.bar_chart_bars = data.map do |data_point|
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

  def run_config_callbacks!
    callbacks = DEFAULT_CALLBACKS + [*config[:bar_chart_callbacks]]

    [*callbacks].each { |c| send("#{c}_callback".to_sym) }
  end

  def sort_by_callback
    return unless sort_by_config.present?

    sort_by_config.each { |sort, key_to_use| send("sort_by_#{sort}".to_sym, key_to_use.to_sym) }
  end

  def sort_by_desc(key)
    self.data = data.sort_by{|d| d[key].nil? ? -1 : d[key].to_f}.reverse!
  end

  def move_all_students_callback
    i = data.find_index { |d| d[:breakdown].downcase == 'all students' }
    data.insert(0, data.delete_at(i)) if i.present?
  end

  def label_for(data_point, config)
    config[:label_charts_with] ? data_point[config[:label_charts_with].to_sym] : nil
  end
end

class DataDisplay
  # Class that holds a collection of graphs related by subject or breakdown.
  # Header and array of chart data.

  attr_accessor :data_points, :data, :config, :title, :sort_by_config

  DEFAULT_BEFORE_CALLBACKS = [ 'sort_by' ]
  DEFAULT_AFTER_CALLBACKS  = []

  def initialize(data, title = nil, config = {})
    # Title is optional because for single chart groups, there is no group title
    self.data = data
    self.config = config
    self.title = title
    self.sort_by_config = config[:sort_by]

    create_data_points!
  end

  private

  def create_data_points!
    run_before_callbacks!

    self.data_points = data.map do |data_point|
      data_point = DataDisplayPoint.new(
        {
          label: label_for(data_point, config),
          value: data_point[:school_value],
          comparison_value: data_point[:state_average],
          performance_level: data_point[:performance_level],
          subtext: data_point[:subtext]
        }
      )
      data_point.display? ? data_point : nil
    end.compact

    run_after_callbacks!
  end

  def run_before_callbacks!
    callbacks = DEFAULT_BEFORE_CALLBACKS + [*config[:data_display_before_callbacks]]

    [*callbacks].each { |c| send("#{c}_callback".to_sym) }
  end

  def run_after_callbacks!
    callbacks = DEFAULT_AFTER_CALLBACKS + [*config[:data_display_after_callbacks]]

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
    i = data.find_index { |d| d[:breakdown].to_s.downcase == 'all students' }
    data.insert(0, data.delete_at(i)) if i.present?
  end

  def label_for(data_point, config)
    config[:label_charts_with] ? data_point[config[:label_charts_with].to_sym] : nil
  end

  def descend_columns_callback
    number_of_rows = (data_points.size / 2).round
    first_half = data_points
    second_half = []
    if number_of_rows > 1
      first_half, second_half = data_points.each_slice(number_of_rows).to_a
    end
    new_data_array = (0..number_of_rows).each_with_object([]) do |i, arr|
      arr << first_half[i] if first_half[i]
      arr << second_half[i] if second_half[i]
    end
    self.data_points = new_data_array
  end
end

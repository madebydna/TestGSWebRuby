class DataDisplay
  # Class that holds a collection of graphs related by subject or breakdown.
  # Header and array of chart data.

  attr_accessor :data_points, :data, :config, :title

  DEFAULT_BEFORE_CALLBACKS = [ 'sort_by' ]
  DEFAULT_AFTER_CALLBACKS  = []

  def initialize(data, title = nil, config = {})
    self.data = data

    # Config options handle things like sorting and labeling data.
    # The current options are:
    # - sort_by: The field in each data point hash to use to sort data by.
    # - label_charts_with: The field in each data point hash to pass to
    #                      DataDisplayPoint as the label field.
    # - data_display_before_callbacks: The set of callback methods in this class
    #                                  to use to transform the data.
    self.config = config

    # Title is optional because for single chart groups, there is no group title
    self.title = title

    create_data_points!
  end

  def display?
    data_points.present?
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

  def label_for(data_point, config)
    config[:label_charts_with] ? data_point[config[:label_charts_with].to_sym] : nil
  end

  def run_before_callbacks!
    callbacks = DEFAULT_BEFORE_CALLBACKS + [*config[:data_display_before_callbacks]]

    [*callbacks].each { |c| send("#{c}_callback".to_sym) }
  end

  def run_after_callbacks!
    callbacks = DEFAULT_AFTER_CALLBACKS + [*config[:data_display_after_callbacks]]

    [*callbacks].each { |c| send("#{c}_callback".to_sym) }
  end

  # Sorts data by evaluating a configured key to use for each data point hash.
  def sort_by_callback
    return unless config[:sort_by].present?

    config[:sort_by].each { |sort, key_to_use| send("sort_by_#{sort}".to_sym, key_to_use.to_sym) }
  end

  # Used by sort_by_callback
  def sort_by_desc(key)
    self.data = data.sort_by{|d| d[key].nil? ? -1 : d[key].to_f}.reverse!
  end

  # Moves the data point with breakdown all students first if there is one.
  def move_all_students_callback
    i = data.find_index { |d| d[:breakdown].to_s.downcase == 'all students' }
    data.insert(0, data.delete_at(i)) if i.present?
  end
end

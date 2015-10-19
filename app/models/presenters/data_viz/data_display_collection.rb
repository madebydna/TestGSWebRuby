class DataDisplayCollection

  # config defines things like title, sub-title, and
  # how to segment charts: by subject or by breakdown.
  # data is a hash of data from GroupComparisonDataReader

  attr_accessor :bar_chart_order, :breakdowns, :config, :data, :default_group,
    :group_by_config, :sub_title, :title, :displays, :original_data_type,
    :partial

  DEFAULT_CALLBACKS = [ 'group_by' ]

  def initialize(title, data, config = {})
    self.data               = data
    self.config             = config
    self.sub_title          = config[:sub_title]
    self.title              = title
    self.default_group      = config[:default_group]
    self.group_by_config    = config[:group_by]
    self.bar_chart_order    = config[:bar_chart_order]
    self.original_data_type = config[title]
    self.partial            = config[:partials][title] if config[:partials]
    create_displays!
    self.breakdowns         = displays.map(&:title) if config[:group_by].present?
  end

  private

  def create_displays!
    run_config_callbacks!

    self.displays = data.map do |name, group_data|
      DataDisplay.new(group_data, name, config) #we assume if there is no title its an ethnicity
    end
  end

  def run_config_callbacks!
    callbacks = DEFAULT_CALLBACKS + [*config[:bar_chart_collection_callbacks]]

    [*callbacks].each { |c| send("#{c}_callback".to_sym) }
  end

  #Grouping callback
  def group_by_callback
    self.data = [*data].group_by { |d| find_group(d) }
  end

  def find_group(data)
    return default_group unless group_by_config.present?

    group_by_config.each do | group, value_to_use |
      found_group = send("find_group_by_#{group}".to_sym, data[value_to_use.to_sym].to_s)
      return found_group if found_group.present?
    end

    default_group
  end

  def find_group_by_gender(str)
    return 'gender' if Genders.all_as_strings.include?(str.downcase)
  end

  def find_group_by_program(str)
    return 'program' if StudentTypes.all_as_strings.include?(str.downcase)
  end

  #Duplicate all students callback
  def copy_all_students_callback
    return unless data.present?
    data_points = data.values.flatten
    all_students = data_points.select { |d| d[:breakdown].to_s.downcase == 'all students' }.first

    if all_students.present?
      data.values.each do | group_of_data |
        group_of_data << all_students unless group_of_data.include?(all_students)
      end
    end
  end

  #Order bar charts callback
  def order_bar_charts_callback
    return unless data.present? && bar_chart_order.present?

    self.data = Hash[data.sort_by { |k, v| bar_chart_order.index(k) }]
  end
end

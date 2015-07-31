class BarChartCollection

  # options defines things like title, sub-title, and
  # how to segment charts: by subject or by breakdown.
  # data is a hash of data from GroupComparisonDataReader

  attr_accessor :bar_charts, :data, :options, :sub_title, :title, :default_group, :group_by_options, :breakdowns

  DEFAULT_CALLBACKS = [:group_by]

  def initialize(title, data, options = {})
    self.data             = data
    self.options          = options
    self.sub_title        = options[:sub_title]
    self.title            = title
    self.default_group    = options[:default_group]
    self.group_by_options = options[:group_by]
    create_bar_charts!
    self.breakdowns       = bar_charts.map(&:title) if options[:group_by].present?
  end

  private

  def create_bar_charts!
    run_config_callbacks!

    self.bar_charts = data.map do |name, group_data|
      BarChart.new(group_data, name, options) #we assume if there is no title its an ethnicity
    end
  end

  def run_config_callbacks!
    callbacks = DEFAULT_CALLBACKS + [*options[:bar_chart_collection_callbacks]]

    [*callbacks].each { |c| send("#{c}_callback".to_sym) }
  end

  #Grouping callback
  def group_by_callback
    self.data = [*data].group_by { |d| find_group(d) }
  end

  def find_group(data)
    return default_group unless group_by_options.present?

    group_by_options.each do | group, value_to_use |
      found_group = send("find_group_by_#{group}".to_sym, data[value_to_use])
      return found_group if found_group.present?
    end

    default_group
  end

  def find_group_by_gender(str)
    return 'gender' if Genders.all_as_strings.include?(str.downcase)
  end

  #Duplicate all students callback
  def copy_all_students_callback
    return unless data.present?
    data_points = data.values.flatten
    all_students = data_points.select { |d| d[:breakdown].downcase == 'all students' }.first

    if all_students.present?
      data.values.each do | group_of_data |
        group_of_data << all_students unless group_of_data.include?(all_students)
      end
    end
  end

end

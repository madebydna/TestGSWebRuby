class DataDisplayCollection

  attr_accessor :breakdowns, :config, :data, :title, :displays,
    :original_data_type, :partial

  DEFAULT_CALLBACKS = [ 'group_by', 'remove_only_all_students' ]

  def initialize(title, data, config = {})
    self.title              = title
    self.data               = data

    # Config options handle things like grouping and sorting data, or which
    # partial to use. The current options are:
    # - collection_callbacks: The set of callback methods in this class to use
    #                         to transform the data.
    # - group_by: Maps 'groups' (e.g. ethnicity, gender) to what values in the
    #             data point hashes should be used to get a data point's group.
    #             A DataDisplay class is created for each group.
    # - data_display_order: The order in which to display DataDisplays.
    self.config             = config

    # The original_data_type is the untranslated label from the config. It is
    # used when we need to have a lookup for things like JS or translations.
    self.original_data_type = config[title]

    # DataDisplayCollections currently support one data display partial at a
    # time. This will be used by the view to render the DataDisplayPoints in
    # this collection with the correct display partial.
    self.partial            = config[:partial]

    create_displays!
  end

  def display?
    displays.present?
  end

  def breakdowns
    displays.map(&:title) if config[:group_by].present?
  end

  private

  def create_displays!
    run_config_callbacks!

    self.displays = data.map do |name, group_data|
      DataDisplay.new(group_data, name, config) #we assume if there is no title its an ethnicity
    end
  end

  def run_config_callbacks!
    callbacks = DEFAULT_CALLBACKS + [*config[:collection_callbacks]]

    [*callbacks].each { |c| send("#{c}_callback".to_sym) }
  end

  #Grouping callback
  def group_by_callback
    self.data = [*data].group_by { |d| find_group(d) }
  end

  def find_group(data)
    if config[:group_by].present?
      config[:group_by].each do | group, value_to_use |
        found_group = send("find_group_by_#{group}".to_sym, data[value_to_use.to_sym].to_s)
        return found_group if found_group.present?
      end
    end
    config[:default_group]
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
  def order_data_displays_callback
    data_display_order = config[:data_display_order]
    return unless data.present? && data_display_order.present?

    self.data = Hash[data.sort_by { |k, v| data_display_order.index(k) }]
  end

  # Remove groups that would only have all students
  def remove_only_all_students_callback
    data.delete_if do |_, values|
      values.map { |v| v[:breakdown].try(:downcase) }.compact.uniq == ['all students']
    end
  end
end

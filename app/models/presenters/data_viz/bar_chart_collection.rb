class BarChartCollection < ActiveRecord::Base

  # options defines things like title, sub-title, and
  # how to segment charts: by subject or by breakdown.
  # data is a hash of data from GroupComparisonDataReader

  attr_accessor :bar_charts, :data, :options, :sub_title, :title

  def initialize(title, data, options = {})
    self.data      = data
    self.options   = options
    self.sub_title = options[:sub_title]
    self.title     = title
    create_bar_charts!
  end

  private

  def create_bar_charts!
    self.bar_charts = grouped_data.map do |name, group_data|
      gd = sort_group(group_data)
      BarChart.new(gd, name, options)
    end
  end

  def grouped_data
    key = options[:create_groups_by]
    data.group_by { |d| find_group(d[key]) }
  end

  def find_group(str)
    callbacks = options[:group_groups_by]

    [*callbacks].each do |c|
      group = send("group_by_#{c}".to_sym, str)
      return group if group.present?
    end
    nil
  end

  def group_by_gender(str)
    return 'gender' if Genders.all_in_strings.include?(str.downcase)
  end

  def sort_group(group_data)
    callbacks = options[:sort_groups_by]

    [*callbacks].inject(group_data) do |gd, c|
      send("sort_by_#{c}".to_sym, gd)
    end
  end

  def sort_by_desc(group_data)
    key = options[:create_sort_by]
    return group_data unless key.present?

    group_data.sort_by{|d| d[key].to_f }.reverse!
  end

  def sort_by_all_students(group_data)
    i = group_data.find_index { |d| d[:breakdown].downcase == 'all students' }
    i.present? ? group_data.insert(0, group_data.delete_at(i)) : group_data
  end

end

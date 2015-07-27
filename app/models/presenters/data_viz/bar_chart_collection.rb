class BarChartCollection < ActiveRecord::Base

  # options defines things like title, sub-title, and
  # how to segment charts: by subject or by breakdown.
  # data is a hash of data from GroupComparisonDataReader

  attr_accessor :bar_charts, :data, :options, :sub_title, :title, :default_group, :breakdowns

  def initialize(title, data, options = {})
    self.data          = data
    self.options       = options
    self.sub_title     = options[:sub_title]
    self.title         = title
    self.default_group = options[:default_group]
    create_bar_charts!
    self.breakdowns    = bar_charts.map(&:title) if options[:create_groups_by].present?
  end

  private

  def create_bar_charts!
    self.bar_charts = grouped_data.map do |name, group_data|
      BarChart.new(group_data, name, options) #we assume if there is no title its an ethnicity
    end
  end

  def grouped_data
    key = options[:create_groups_by]
    data.group_by { |d| find_group(d[key]) }
  end

  def find_group(str)
    callbacks = options[:group_groups_by]

    [*callbacks].each do |c|
      group = send("find_group_by_#{c}".to_sym, str)
      return group if group.present?
    end
    default_group
  end

  def find_group_by_gender(str)
    return 'gender' if Genders.all_as_strings.include?(str.downcase)
  end

end

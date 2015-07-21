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
    grouped_data = data.group_by { |d| d[options[:create_groups_by]] }
    self.bar_charts = grouped_data.map do |name, group_data|
      BarChart.new(group_data, name, options)
    end
  end
end

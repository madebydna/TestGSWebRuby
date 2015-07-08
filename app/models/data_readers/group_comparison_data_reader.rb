# The Group Comparison data reader.
# Right now this is just set up to work with bar charts.
# Bar charts are organized into group_collections and groups.
#
# bar_chart_group_collection is the first-order grouping of charts.
# - It has things like the name that goes on the button and knows how to
#   segment the data into the smaller bar_chart_group's
# bar_chart_group is the second-order grouping of charts.
# - It has a title and knows how to create the bar_charts underneath it.
# - It also knows why its charts are related. For instance, this will often
#   be a collection of results for one student breakdown over multiple years.
#
# EXAMPLES:
# 1. Student group comparison.
#  - Each bar_chart_group_collection is for a data type and creates
#    bar_chart_groups for each student breakdown, like ethnicity.
#  - Each bar_chart_group is therefore for a student breakdown. In this
#    example, let's pretend we aren't showing data over time, so we aren't
#    segmenting the groups further. Thus, each bar_chart_group has only one
#    bar_chart in it.
# 2. Test scores by subject.
#  - Each bar_chart_group_collection is for a subject (the whole thing is test
#    results for a single test, or more technically, TestDataType). We're
#    again segments by breakdown, so this creates bar_chart_groups for each
#    breakdown.
#  - Each bar_chart_group is for a breakdown and we're also looking at data by
#    year so each bar_chart_group creates bar_charts within it for each year.

class GroupComparisonDataReader < SchoolProfileDataReader
  include CachedCategoryDataConcerns

  # An array of BarChartGroupCollection objects.
  # Each of these has inner objects of groups of charts and then the
  # charts themselves.
  def data_for_category(category)
    data = cached_data_for_category(category, 'characteristics', school)
    config = {
      create_groups_by: nil,
      create_charts_by: :breakdown,
      label_charts_with: :breakdown,
    }
    data.map do |collection_name, collection_data|
      BarChartGroupCollection.new(collection_name, collection_data, config)
    end
  end
end

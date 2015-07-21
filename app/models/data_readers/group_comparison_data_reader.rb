# The Group Comparison data reader.
# Right now this is just set up to work with bar charts.
# Bar charts are organized into group_collections and groups.
#
# BarChartCollection is the first-order grouping of charts.
# - It has things like the name that goes on the button and knows how to
#   segment the data into the smaller BarChart's
# BarChart is the second-order grouping of charts.
# - It has a title and knows how to create the BarChartBars underneath it.
# - It also knows why its charts are related. For instance, this will often
#   be a collection of results for one student breakdown over multiple years.
#
# EXAMPLES:
# 1. Student group comparison.
#  - Each BarChartCollection is for a data type and creates
#    BarCharts for each student breakdown, like ethnicity.
#  - Each BarChart is therefore for a student breakdown. In this
#    example, let's pretend we aren't showing data over time, so we aren't
#    segmenting the groups further. Thus, each BarChart has only one
#    BarChartBar in it.
# 2. Test scores by subject.
#  - Each BarChartCollection is for a subject (the whole thing is test
#    results for a single test, or more technically, TestDataType). We're
#    again segments by breakdown, so this creates BarCharts for each
#    breakdown.
#  - Each BarChart is for a breakdown and we're also looking at data by
#    year so each BarChart creates BarChartBars within it for each year.

class GroupComparisonDataReader < SchoolProfileDataReader
  include CachedCategoryDataConcerns

  # An array of BarChartCollection objects.
  # Each of these has inner objects of groups of charts and then the
  # charts themselves.
  def data_for_category(category)
    config = {
      create_groups_by: nil,
      create_charts_by: :breakdown,
      label_charts_with: :breakdown,
      breakdown: 'Ethnicity',
      breakdown_all: 'Enrollment'
    }

    data = get_data(category, config)

    data.map do |collection_name, collection_data|
      BarChartCollection.new(collection_name, collection_data, config)
    end
  end

  def get_data(category, config)
    data = cached_data_for_category(category, 'characteristics', school)
    modify_data!(data, config)
  end

  #this code exists to modify the data from school cache and make it more friendly for the Bar Charts
  #However, consider moving this calculation to school cache and precalculate it there.
  def modify_data!(data, config)
    modify_data_callbacks.inject(data) { | d, callback | send(callback, d, config) }
  end

  def modify_data_callbacks
    [:add_ethnicity_callback, :add_enrollment_callback]
  end

  def add_ethnicity_callback(data, config)
    return data unless config[:breakdown] == 'Ethnicity'

    ethnicity_data = get_cache_data('characteristics', :Ethnicity, school)[:Ethnicity]
    ethnicity_map = ethnicity_data.inject({}) do | h, ethnicity |
      h.merge(ethnicity[:breakdown] => ethnicity[:school_value])
    end

    data.values.flatten.each do | hash |
      if (ethnicity_percent = ethnicity_map[hash[:breakdown]]).present?
        hash[:subtext] = "#{ethnicity_percent.to_i}% of population"
      else
        hash[:subtext] = "no data"
      end
    end

    data
  rescue
    data
  end

  def add_enrollment_callback(data, config)
    return data unless config[:breakdown_all] == 'Enrollment'

    enrollment_data = get_cache_data('characteristics', :Enrollment, school)[:Enrollment]
    enrollment_size = enrollment_data.first[:school_value].to_i

    data.values.flatten.each do | hash |
      hash[:subtext] = "#{enrollment_size} students tested" if hash[:breakdown].downcase == 'all students'
    end

    data
  rescue
    data
  end

end

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

  attr_accessor :category, :config, :data

  # An array of BarChartCollection objects.
  # Each of these has inner objects of groups of charts and then the
  # charts themselves.
  def data_for_category(category)
    self.category = category

    self.config = {
      create_groups_by: :breakdown,
      group_groups_by: [:gender],
      create_sort_by: :school_value,
      sort_groups_by: [:desc, :all_students],
      create_charts_by: :breakdown,
      label_charts_with: :breakdown,
      breakdown: 'Ethnicity',
      breakdown_all: 'Enrollment'
    }

    get_data!

    data.map do |collection_name, collection_data|
      BarChartCollection.new(collection_name, collection_data, config)
    end
  end

  protected

  def get_data!
    self.data = cached_data_for_category(category, 'characteristics', school)
    modify_data!
  end

  #this code exists to modify the data from school cache and make it more friendly for the Bar Charts
  #However, consider moving this calculation to school cache and precalculate it there.
  def modify_data!
    modify_data_callbacks.each { |callback| send(callback) }
  end

  def modify_data_callbacks
    [
      :change_data_type_to_label,
      :add_ethnicity_callback,
      :add_enrollment_callback,
      :add_student_types_callback,
    ]
  end

  def change_data_type_to_label
    data.transform_keys! { |key| category.key_label_map[key.to_s] }
  end

  def add_ethnicity_callback
    return data unless config[:breakdown] == 'Ethnicity'

    ethnicity_data = get_cache_data('characteristics', :Ethnicity, school)[:Ethnicity]
    ethnicity_map = ethnicity_data.inject({}) do | h, ethnicity |
      h.merge(ethnicity[:breakdown] => ethnicity[:school_value])
    end

    data.values.flatten.each do | hash |
      if (ethnicity_percent = ethnicity_map[hash[:breakdown]]).present?
        hash[:subtext] = percent_of_population_text(ethnicity_percent)
      elsif hash[:subtext].nil?
        hash[:subtext] = no_data_text
      end
    end

    data
  rescue
    data
  end

  def add_enrollment_callback
    return data unless config[:breakdown_all] == 'Enrollment'

    enrollment_data = get_cache_data('characteristics', :Enrollment, school)[:Enrollment]
    enrollment_size = enrollment_data.first[:school_value]

    data.values.flatten.each do | hash |
      if hash[:breakdown].downcase == 'all students'
        if enrollment_size
          hash[:subtext] = I18n.t(
            :number_tested_subtext,
            number: enrollment_size.to_i,
            scope: i18n_scope,
            default: "#{enrollment_size} students tested"
          )
        elsif hash[:subtext].nil?
          hash[:subtext] = no_data_text
        end
      end
    end

    data
  rescue
    data
  end

  def add_student_types_callback
    genders = get_cache_data('characteristics', Genders.all + StudentTypes.all, school)
    genders.each do | gender, data |
      genders[gender] = data.first[:school_value]
    end

    data.values.flatten.each do | hash |
      if (gender_percent = genders[hash[:breakdown].to_s.to_sym]).present?
        hash[:subtext] = percent_of_population_text(gender_percent)
      elsif hash[:subtext].nil?
        hash[:subtext] = no_data_text
      end
    end

    data
  rescue
    data
  end

  def i18n_scope
    self.class.name.underscore
  end

  def percent_of_population_text(percent)
    I18n.t(
      :percent_of_population_subtext,
      percent: percent.to_i,
      scope: i18n_scope,
      default:"#{percent.to_i}% of population"
    )
  end

  def no_data_text
    I18n.t(
      :no_data_subtext,
      scope: i18n_scope,
      default:"No data"
    )
  end
end

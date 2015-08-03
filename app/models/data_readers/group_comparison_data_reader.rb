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

  DEFAULT_CALLBACKS = [ 'change_data_type_to_label' ]

  attr_accessor :category, :config, :data

  # An array of BarChartCollection objects.
  # Each of these has inner objects of groups of charts and then the
  # charts themselves.
  def data_for_category(category)
    self.category = category
    self.config = category.parsed_json_config

    # example parsed config. (HashWithIndifferentAccess)
    # self.config = {
    #  'bar_chart_collection_callbacks' => ['copy_all_students'],
    #  'group_by'                       => {'gender '=> 'breakdown'},
    #  'default_group'                  => 'ethnicity',
    #  'bar_chart_callbacks'            => ['move_all_students'],
    #  'sort_by'                        => 'desc' => 'percent_of_population'},
    #  'label_charts_with'              => 'breakdown',
    #  'breakdown'                      => 'Ethnicity',
    #  'breakdown_all'                  => 'Enrollment',
    #  'group_comparison_callbacks'     => [
    #     'add_ethnicity_callback',
    #     'add_enrollment_callback',
    #     'add_student_types_callback',
    #   ]
    # }

    get_data!

    bar_chart_collections = data.map do |collection_name, collection_data|
      BarChartCollection.new(collection_name, collection_data, config)
    end
    {
      partner: 'innovate_public_schools',
      bar_chart_collections: bar_chart_collections,
    }
  rescue
    {}
  end

  protected

  def get_data!
    self.data = cached_data_for_category(category, 'characteristics', school)
    modify_data!
  end

  def modify_data!
    modify_data_callbacks.each { |callback| send(callback) }
  end

  def modify_data_callbacks
    DEFAULT_CALLBACKS + [*config[:group_comparison_callbacks]]
  end

  def change_data_type_to_label
    data.transform_keys! { |key| category.key_label_map[key.to_s] }
  end

  def add_ethnicity_callback
    ethnicity_sym = SchoolCache::ETHNICITY
    return unless config[:breakdown] == ethnicity_sym.to_s

    ethnicity_data = get_cache_data('characteristics', ethnicity_sym, school)[ethnicity_sym]
    ethnicity_map = ethnicity_data.inject({}) do | h, ethnicity |
      h.merge(ethnicity[:original_breakdown] => ethnicity[:school_value])
    end

    data.values.flatten.each do | hash |
      if (ethnicity_percent = ethnicity_map[hash[:original_breakdown]]).present?
        hash[:subtext] = percent_of_population_text(ethnicity_percent)
        hash[:percent_of_population] = ethnicity_percent
      elsif hash[:subtext].nil?
        hash[:subtext] = no_data_text
      end
    end
  end

  def add_enrollment_callback
    enrollment_sym = SchoolCache::ENROLLMENT
    return unless config[:breakdown_all] == enrollment_sym.to_s

    enrollment_data = get_cache_data('characteristics', enrollment_sym, school)[enrollment_sym]
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

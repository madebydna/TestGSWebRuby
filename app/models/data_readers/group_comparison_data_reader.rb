# The Group Comparison data reader.
# Data display points are organized into collections and displays.
#
# DataDisplayCollection is the first-order grouping of charts.
# - It has things like the name that goes on the button and knows how to
#   segment the data into the smaller DataDisplay's
# DataDisplay is the second-order grouping of charts.
# - It has a title and knows how to create the DataDisplayPoints underneath it.
# - It also knows why its charts are related. For instance, this will often
#   be a collection of results for one student breakdown over multiple years.
#
# EXAMPLES:
# 1. Student group comparison.
#  - Each DataDisplayCollection is for a data type and creates
#    DataDisplays for each student breakdown, like ethnicity.
#  - Each DataDisplay is therefore for a student breakdown. In this
#    example, let's pretend we aren't showing data over time, so we aren't
#    segmenting the groups further. Thus, each DataDisplay has only one
#    DataDisplayPoint in it.
# 2. Test scores by subject.
#  - Each DataDisplayCollection is for a subject (the whole thing is test
#    results for a single test, or more technically, TestDataType). We're
#    again segments by breakdown, so this creates DataDisplays for each
#    breakdown.
#  - Each DataDisplay is for a breakdown and we're also looking at data by
#    year so each DataDisplay creates DataDisplayPoints within it for each year.

class GroupComparisonDataReader < SchoolProfileDataReader
  include CachedCategoryDataConcerns

  DEFAULT_CALLBACKS = [ 'transform_data_keys!' ]
  SCHOOL_CACHE_KEYS = [ 'characteristics', 'performance' ]

  attr_accessor :category, :config, :data

  # An array of DataDisplayCollection objects.
  # Each of these has inner objects of groups of charts and then the
  # charts themselves.
  def data_for_category(category)
    self.category = category
    self.config = category.parsed_json_config

    # example JSON config. Gets turned into a HashWithIndifferentAccess.
    # The format of the keys is partial:config_key.
    # {
    #   "all:collection_callbacks": [
    #     "copy_all_students",
    #     "order_data_displays"
    #   ],
    #   "all:order": [
    #     "ethnicity",
    #     "program",
    #     "gender"
    #   ],
    #   "all:group_by": {
    #     "gender": "breakdown",
    #     "program": "breakdown"
    #   },
    #   "all:default_group": "ethnicity",
    #   "bar_chart:data_display_callbacks": [
    #     "move_all_students",
    #     "descend_columns"
    #   ],
    #   "rating:data_display_callbacks": [
    #     "move_all_students"
    #   ],
    #   "all:sort_by": {
    #     "desc": "percent_of_population"
    #   },
    #   "all:label_charts_with": "breakdown",
    #   "breakdown": "Ethnicity",
    #   "breakdown_all": "Enrollment",
    #   "group_comparison_callbacks": [
    #     "add_ethnicity_callback",
    #     "add_enrollment_callback",
    #     "add_student_types_callback"
    #   ]
    # }
    get_data!
    configure_data_type_partials!
    data_display_collections

  rescue
    []
  end

  protected

  # Maps all data point hashes to a data display collection. The array of these
  # is what is passed to the view.
  def data_display_collections
    data_display_collections = data.map do |label_array, collection_data|
      original_label, collection_name = label_array[0], label_array[1]
      collection_config = config_for_collection(collection_name, original_label)
      DataDisplayCollection.new(collection_name, collection_data, collection_config)
    end
    valid_collections(data_display_collections)
  end

  def valid_collections(data_display_collections)
    data_display_collections.keep_if { |collection| collection.display? }
  end

  # Collections can have different configurations based on what display
  # partial it is using. This method returns only the parts of the config hash
  # relevant to a collection and strips out the partial's prefix. See the main
  # method of this data reader for the config's format, including data display
  # partial prefixes.
  #
  # The return value is a hash of config values. This does not modify self.config.
  #
  # For example, for a bar_chart collection, this changes this config:
  # {
  #   "all:default_group": "ethnicity",
  #   "bar_chart:data_display_callbacks": [
  #     "move_all_students",
  #     "bar_chart_specific_callback"
  #   ],
  #   "rating:data_display_callbacks": [
  #     "move_all_students",
  #     "rating_specific_callback"
  #   ],
  #   "all:sort_by": {
  #     "desc": "percent_of_population"
  #   },
  # }
  # into this config:
  # {
  #   "default_group": "ethnicity",
  #   "data_display_callbacks": [
  #     "move_all_students",
  #     "bar_chart_specific_callback"
  #   ],
  #   "sort_by": {
  #     "desc": "percent_of_population"
  #   },
  # }
  def config_for_collection(collection_name, original_label)
    config["all:#{collection_name}"] = original_label
    collection_partial = config[:partials][collection_name].to_s
    config.each_with_object({}.with_indifferent_access) do |(key, value), h|
      config_partial = key.split(':').first
      if config_partial == collection_partial || config_partial == 'all'
        config_key = key.sub("#{config_partial}:", '')
        h[config_key] = value
      end
    end.merge( partial: collection_partial )
  end

  def get_data!
    data = cached_data_for_category
    data = data.each_with_object({}) do |(key, array_of_data_objects), hash|
      hash[key] = select_data_with_max_year(array_of_data_objects)
    end
    self.data = data
    modify_data!
  end

  def select_data_with_max_year(array_of_data_objects)
    max_year = array_of_data_objects.map { |o| o[:year] }.max
    array_of_data_objects.select { |o| o[:year] == max_year }
  end

  def modify_data!
    modify_data_callbacks.each { |callback| send(callback) }
  end

  def modify_data_callbacks
    DEFAULT_CALLBACKS + [*config[:group_comparison_callbacks]]
  end

  def configure_data_type_partials!
    config[:partials] = category.category_data.each_with_object({}) do |cd, h|
      h[cd.label] = cd.display_type || :bar_chart
    end
  end

  def footnotes_for_category(category)
    data = cached_data_for_category
    data.map do |_, data_hashes|
      data_hash = data_hashes.first
      if data_hash[:source] && data_hash[:year]
        { source: data_hash[:source], year: data_hash[:year] }
      end
    end.compact
  end

  ############################# CALLBACK METHODS ###############################

  # Gets school level ethnicity percentages from school cache and adds them to
  # each data point hash as :percent_of_population and :subext keys.
  def add_ethnicity_callback
    ethnicity_sym = SchoolCache::ETHNICITY
    return unless config[:breakdown] == ethnicity_sym.to_s

    ethnicity_data = get_cache_data(data_type: ethnicity_sym)[[ethnicity_sym, nil]]
    if ethnicity_data
      ethnicity_map = ethnicity_data.inject({}) do | h, ethnicity |
        h.merge(ethnicity[:original_breakdown] => ethnicity[:school_value])
      end
      add_percents_of_population!(ethnicity_map)
    end
  end

  # Gets school level student types percentages from school cache and adds them
  # to each data point hash as :percent_of_population and :subext keys.
  # A student type is something like % English Learners or % Male.
  def add_student_types_callback
    all_types = Genders.all + StudentTypes.all_datatypes
    student_types_data = get_cache_data(all_types.map { |t| { data_type: t } })
    student_types = student_types_data.inject({}) do | h, (type, type_data) |
      # Student types aren't necessarily the same name as their breakdowns so we
      # map the datatype (used above to get the data) to its breakdown here.
      breakdown = StudentTypes.datatype_to_breakdown(type.first.to_s)
      h.merge(breakdown => type_data.first[:school_value])
    end
    add_percents_of_population!(student_types)
  end

  def add_percents_of_population!(percents_of_population)
    data.values.flatten.each do | hash |
      percent = percents_of_population[hash[:original_breakdown]]
      if percent.present?
        hash[:subtext] = percent_of_population_text(percent)
        hash[:percent_of_population] = percent
      elsif hash[:subtext].nil?
        hash[:subtext] = no_data_text
      end
    end
  end

  # Gets school level student enrollment from school cache and adds some text
  # about it to the all students data point hash as a :subext key.
  def add_enrollment_callback
    enrollment_sym = SchoolCache::ENROLLMENT
    enrollment_cache_data_value_key = [enrollment_sym, nil]

    return unless config[:breakdown_all] == enrollment_sym.to_s

    cache_data_for_enrollment = get_cache_data(data_type: enrollment_sym)

    return unless cache_data_for_enrollment.has_key?(enrollment_cache_data_value_key)

    enrollment_data = cache_data_for_enrollment[enrollment_cache_data_value_key]
    enrollment_size = enrollment_data.first[:school_value]
    data.values.flatten.each do | hash |
      if hash[:breakdown].to_s.downcase == 'all students'
        if enrollment_size
          hash[:subtext] = number_students_text(enrollment_size.to_i)
        elsif hash[:subtext].nil?
          hash[:subtext] = no_data_text
        end
      end
    end
  end

  # General education is supposed to be the converse of special education, but
  # it's confusing to parents. This callback removes data points for that
  # breakdown.
  def remove_general_eduation_callback
    data.each do | key, _ |
      data[key].delete_if do |data_point|
        data_point[:original_breakdown] == StudentTypes.general_education_breakdown_label
      end
    end
  end

  ############################# CALLBACK HELPERS ###############################

  def i18n_scope
    self.class.name.underscore
  end

  def percent_of_population_text(percent)
    I18n.t(
      :percent_of_population_subtext,
      percent: (percent < 1 && percent > 0 ? '<1' : percent.to_i),
      scope: i18n_scope,
      default:"#{percent}% of population"
    )
  end

  def number_students_text(enrollment)
    I18n.t(
      :number_tested_subtext,
      number: enrollment,
      scope: i18n_scope,
      default: "#{enrollment} students"
    )
  end

  def no_data_text
    '&nbsp;'.html_safe
  end

  ########################## END CALLBACK SECTION ##############################
end

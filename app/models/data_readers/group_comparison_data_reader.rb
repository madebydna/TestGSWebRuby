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

  DEFAULT_CALLBACKS = [ 'preserve_data_type_name', 'change_data_type_to_label' ]
  SCHOOL_CACHE_KEYS = [ 'characteristics', 'performance' ]

  attr_accessor :category, :config, :data

  # An array of DataDisplayCollection objects.
  # Each of these has inner objects of groups of charts and then the
  # charts themselves.
  def data_for_category(category)
    self.category = category
    self.config = category.parsed_json_config

    # example parsed config. (HashWithIndifferentAccess)
    # self.config = {
    #  'bar_chart_collection_callbacks' => ['copy_all_students'],
    #  'group_by'                       => {'gender'=> 'breakdown', 'program' => 'breakdown'},
    #  'default_group'                  => 'ethnicity',
    #  'bar_chart_callbacks'            => ['move_all_students'],
    #  'sort_by'                        => {'desc' => 'percent_of_population'},
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
    configure_data_type_partials!
    data_display_collections

  rescue
    []
  end

  protected

  def data_display_collections
    collections = data.map do |collection_name, collection_data|
      collection_name = collection_name.first
      collection_config = config_for_collection(collection_name)
      DataDisplayCollection.new(collection_name, collection_data, collection_config)
    end
    if valid_data_display_collections?(collections)
      collections
    else
      []
    end
  end

  def valid_data_display_collections?(data_display_collections)
    data_display_collections.any? do |data_display_collection|
      data_display_collection.displays.any? { |bc| bc.data_points.present? }
    end
  end

  def config_for_collection(collection_name)
    collection_partial = config[:partials][collection_name].to_s
    config.each_with_object({}.with_indifferent_access) do |(key, value), h|
      config_partial = key.split(':').first
      if config_partial == collection_partial || config_partial == 'all'
        config_key = key.sub("#{config_partial}:", '')
        h[config_key] = value
      end
    end.merge( partial: collection_partial )
  end

  def school_cache_keys
    SCHOOL_CACHE_KEYS
  end

  def get_data!
    self.data = cached_data_for_category
    modify_data!
  end

  def modify_data!
    modify_data_callbacks.each { |callback| send(callback) }
  end

  def modify_data_callbacks
    DEFAULT_CALLBACKS + [*config[:group_comparison_callbacks]]
  end

  def preserve_data_type_name
    translated_label_map = category.key_label_map(true, true)
    untranslated_label_map = category.key_label_map(false, true)
    data.each do |key, _|
      key = label_lookup_value(key)
      config["all:#{translated_label_map[key]}"] = untranslated_label_map[key]
    end
  end

  def change_data_type_to_label
    data.transform_keys! do |key|
      label = category.key_label_map(true, true)[label_lookup_value(key)]
      [label, key.last]
    end
  end

  def label_lookup_value(key)
    [key.first.to_s, key.last]
  end

  def configure_data_type_partials!
    config[:partials] = category.category_data.each_with_object({}) do |cd, h|
      h[cd.label] = cd.display_type || :bar_chart
    end
  end

  def add_ethnicity_callback
    ethnicity_sym = SchoolCache::ETHNICITY
    return unless config[:breakdown] == ethnicity_sym.to_s

    ethnicity_data = get_cache_data(data_type: ethnicity_sym)[[ethnicity_sym, nil]]
    if ethnicity_data
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
  end

  def add_enrollment_callback
    enrollment_sym = SchoolCache::ENROLLMENT
    return unless config[:breakdown_all] == enrollment_sym.to_s

    enrollment_data = get_cache_data(data_type: enrollment_sym)[[enrollment_sym, nil]]
    enrollment_size = enrollment_data.first[:school_value]

    data.values.flatten.each do | hash |
      if hash[:breakdown].to_s.downcase == 'all students'
        if enrollment_size
          hash[:subtext] = I18n.t(
            :number_tested_subtext,
            number: enrollment_size.to_i,
            scope: i18n_scope,
            default: "#{enrollment_size} students"
          )
        elsif hash[:subtext].nil?
          hash[:subtext] = no_data_text
        end
      end
    end
  end

  def add_student_types_callback
    all_types = Genders.all + StudentTypes.all_datatypes
    student_types_data = get_cache_data(all_types.map { |t| { data_type: t } })
    student_types = student_types_data.inject({}) do | h, (type, type_data) |
      # Student types aren't the same name as their breakdowns so we map the
      # datatype (used above to get the data) to its breakdown here. See AT-925.
      breakdown = if (student_type = StudentTypes.datatype_to_breakdown[type.first.to_s])
                    student_type.to_sym
                  else
                    type.first
                  end
      h.merge(breakdown => type_data.first[:school_value])
    end

    data.values.flatten.each do | hash |
      if (percent = student_types[hash[:breakdown].to_s.to_sym]).present?
        hash[:subtext] = percent_of_population_text(percent)
        hash[:percent_of_population] = percent
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
      percent: (percent < 1 && percent > 0 ? '<1' : percent.to_i),
      scope: i18n_scope,
      default:"#{percent}% of population"
    )
  end

  def no_data_text
    '&nbsp;'.html_safe
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
end

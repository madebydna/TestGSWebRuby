class PerformanceDataReader < SchoolProfileDataReader
  include CachedCategoryDataConcerns

  # Yes, yes, we know it's silly that the PerformanceDataReader pulls from
  # characteristics, but that's just how the data is organized right now...
  SCHOOL_CACHE_KEYS = [ 'characteristics', 'performance' ]

  # example config
  # {
  #   'breakdown_mappings' => {
  #     'Low-Income students' => 'Economically disadvantaged'
  #   }
  # }
  attr_accessor :category, :config, :data

  def data_for_category(category)
    self.category = category
    self.config = category.parsed_json_config

    get_data!
    transform_data_keys!
    data_display_points
  rescue
    []
  end

  protected

  def get_data!
    self.data = cached_data_for_category
  end

  def data_display_points
    data.each_with_object([]) do |(label_array, values), data_points|
      original_label, label = label_array[0], label_array[1]
      config[label] = original_label
      data_points << select_breakdown_with_label(values, original_label).map do |value|
        data_point = DataDisplayPoint.new(
          {
            label: label,
            original_label: value[:original_breakdown],
            value: value[:school_value],
            comparison_value: value[:state_average],
            performance_level: value[:performance_level],
            subtext: value[:subtext],
            description: description_for(original_label),
            link_to: config[:link_mappings].try(:[], config[label]),
          }
        )
        data_point.display? ? data_point : nil
      end.compact
    end.flatten
  end

  def description_for(data_type)
    if data_type.present?
      normalized_data_type = data_type.gsub(' ', '_').underscore
      I18n.t("models.data_readers.performance_data_reader.#{normalized_data_type}_html")
    end
  end

end

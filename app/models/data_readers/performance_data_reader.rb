class PerformanceDataReader < SchoolProfileDataReader
  include CachedCategoryDataConcerns

  # Yes, yes, we know it's silly that the PerformanceDataReader pulls from
  # characteristics, but that's just how the data is organized right now...
  SCHOOL_CACHE_KEYS = [ 'characteristics', 'performance' ]

  #164 test score rating
  #165 student growth rating
  #166 college readiness rating
  #174 + low income breakdown  great schools rating
  # {
  #   'breakdown_mappings' => {
  #     'Low-income student rating' => 'Economically disadvantaged'
  #   }
  # }
  attr_accessor :category, :category_data_school_cache_map, :config, :data

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
    #data and category_data_school_cache_map need same args
    self.data = cached_data_for_category
    preserve_data_type_name(prefix: '')
    self.category_data_school_cache_map = category_data_key_map.each_with_object({}) do |(cd, key_map), map|
      map[cd] = key_map.values #ex key_map = { data_type: 'Great Schools Rating', subject: nil }
    end
  end

  def transform_data_keys!
    self.data = category_data.each_with_object({}) do | cd, new_data |
                  data_key = category_data_school_cache_map[cd]
                  if (value_hash = data[data_key]).present?
                    new_data.merge!({[cd.label(false), cd.label, data_key.last] => value_hash.deep_dup})
                  end
                end
  end

  def school_cache_keys
    SCHOOL_CACHE_KEYS
  end

  def breakdown_data_for(label)
    breakdown = config[:breakdown_mappings].try(:[], label) || 'all students'
    Proc.new { |d| d[:breakdown].try(:downcase) == breakdown.try(:downcase) }
  end

  def data_display_points
    data.each_with_object([]) do |(label_array, values), data_points|
      original_label, label = label_array[0], label_array[1]
      breakdown_match = breakdown_data_for(original_label)
      data_points << values.select(&breakdown_match).map do |value|
        data_point = DataDisplayPoint.new(
          {
            label: label,
            value: value[:school_value],
            comparison_value: value[:state_average],
            performance_level: value[:performance_level],
            subtext: value[:subtext],
            link_to: config[:link_mappings].try(:[], config[label]),
          }
        )
        data_point.display? ? data_point : nil
      end.compact
    end.flatten
  end
end

class PerformanceDataReader < SchoolProfileDataReader
  include CachedCategoryDataConcerns

  # Yes, yes, we know it's silly that the PerformanceDataReader pulls from
  # characteristics, but that's just how the data is organized right now...
  SCHOOL_CACHE_KEYS = [ 'characteristics', 'performance' ]

  attr_accessor :category, :config, :data

  def data_for_category(category)
    self.category = category

    get_data!
    data_display_points
  rescue
    []
  end

  protected

  def get_data!
    self.data = cached_data_for_category

    data.transform_keys! do |key|
      label = category.key_label_map(true, true)[label_lookup_value(key)]
      [label, key.last]
    end
  end

  def school_cache_keys
    SCHOOL_CACHE_KEYS
  end

  def label_lookup_value(key)
    [key.first.to_s, key.last]
  end

  def all_students_data
    Proc.new { |d| d[:breakdown].try(:downcase) == 'all students' }
  end

  def data_display_points
    data.each_with_object([]) do |(label_array, values), data_points|
      label = label_array.first
      data_points << values.select(&all_students_data).map do |value|
        data_point = DataDisplayPoint.new(
          {
            label: label,
            value: value[:school_value],
            comparison_value: value[:state_average],
            performance_level: value[:performance_level],
            subtext: value[:subtext]
          }
        )
        data_point.display? ? data_point : nil
      end.compact
    end.flatten
  end
end

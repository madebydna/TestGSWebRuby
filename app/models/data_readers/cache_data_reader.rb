class CacheDataReader < SchoolProfileDataReader
  include CachedCategoryDataConcerns

  # Yes, yes, we know it's silly that the PerformanceDataReader pulls from
  # characteristics, but that's just how the data is organized right now...
  SCHOOL_CACHE_KEYS = [ 'characteristics', 'performance', 'esp_responses' ]

  # example config
  # {
  #   'breakdown_mappings' => {
  #     'Low-Income students' => 'Economically disadvantaged'
  #   }
  # }
  attr_accessor :category, :config, :data

  def data_for_category(category)
    require'pry';binding.pry
    self.category = category
    self.config = category.parsed_json_config
    get_data!
    transform_data_keys!
    data 
  rescue
    []
  end

  protected

  def get_data!
    self.data = cached_data_for_category
  end

end

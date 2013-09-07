class EspResponseReader
  attr_reader :category

  def initialize(category)
    @category = category
  end

  def query(school)
    osp_data = SchoolCategoryData.where(school_id: school.id)
  end

  # handle checking request-scoped cached results, maybe get a higher-level resultset and filter out unneeded data
  # maybe actually run the query() method
  # return map of response_key to array of values
  def data(school)
    key_label_map = @category.key_label_map(school.collections)

    # We grabbed all the school's data, so we need to filter out rows that dont have the keys that we need
    data = query(school).select! { |data| key_label_map.keys.include? data.key}

    # since esp_response has multiple rows with the same key, roll up all values for a key into an array
    data.inject({}) do |hash, school_data|
      key = school_data['key']
      hash[key] ||= []
      hash[key] << school_data['value']
      hash
    end
  end

  def table_data(school)
    # now that we have a map of key => array of values, create an array with one element for each pair
    # This is what the view / layout code expects
    table_data = TableData.new

    data(school).each_pair do |key, value|
      table_data.add_row ({
          label: key,
          value: value
      })
    end
    table_data
  end

  def prettify_data(school, table_data)
    key_label_map = category.key_label_map(school.collections)

    table_data.transform! :label, key_label_map
    table_data.transform! :value, ResponseValue.lookup_table(school.collections)
  end

end
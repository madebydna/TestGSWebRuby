class EspResponseReader
  attr_reader :category

  def initialize(category)
    @category = category
  end

  def query(school)
    EspResponse.using(school.state.upcase.to_sym).where(school_id: school.id)
  end

  # handle checking request-scoped cached results, maybe get a higher-level resultset and filter out unneeded data
  # maybe actually run the query() method
  # return map of response_key to array of values
  def data(school)
    keys_to_use = @category.category_data(school.collections).map(&:response_key)

    # We grabbed all the school's data, so we need to filter out rows that dont have the keys that we need
    data = query(school).select! { |response| keys_to_use.include? response.response_key}

    unless data.nil?
      # since esp_response has multiple rows with the same key, roll up all values for a key into an array
      blah = data.inject({}) do |hash, response|
        key = response.response_key
        hash[key] ||= []
        hash[key] << response.response_value
        hash
      end
    end
  end

  def table_data(school)
    # now that we have a map of key => array of values, create an array with one element for each pair
    # This is what the view / layout code expects
    table_data = TableData.new

    unless data(school).nil?
      data(school).each_pair do |key, value|
        table_data.add_row ({
            label: key,
            value: value
        })
      end
    end
    table_data
  end

  def prettify_data(school, table_data)
    lookup_table = ResponseValue.lookup_table(school.collections)
    table_data.transform! :label, lookup_table
    table_data.transform! :value, lookup_table
  end

end
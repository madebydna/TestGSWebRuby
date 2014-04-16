class EspDataReader < SchoolProfileDataReader

  def data_for_category(category)
    responses_per_key = responses_for_category(category)

    # Next, we want to transform the response keys and values into their
    # "pretty" versions. The order in which we do this is important.
    # The pretty labels for response_values are sometimes broken down
    # by response_key, and the response_keys used are the "raw" unprettified
    # versions. If we transform the keys first, the values won't transform
    # correctly
    prettify_response_key_to_responses_hash! responses_per_key

    # Originally we were making esp_response return a simple hash of key value
    # pairs. But due to a requirement We need to return an array of hashes,
    # where each hash has a key, label, and value(s). This is because we want
    # to support multiple items with the same label. An array of 2-element
    # arrays would work, but this is more flexible
    array_of_hashes = []

    keys_and_labels = category.key_label_map
    responses_per_key.each do |key, values|
      label = keys_and_labels[key] || key
      array_of_hashes << {
        key: key,
        label: label,
        value: values
      }
    end

    array_of_hashes
  end

  def prettify_response_key_to_responses_hash!(hash)
    # First, get hash of response value string to ResponseValue
    lookup_table = self.esp_lookup_table

    # Transform the values
    hash.each do |key, values|
      values.map! do |value|
        lookup_value = lookup_table[[key, value]]
        if lookup_value.nil?
          value
        else
          lookup_value
        end
      end
    end
  end

  # get hash of response value string to ResponseValue
  def esp_lookup_table
    ResponseValue.lookup_table
  end

  # Instead of the hash values being EspResponse objects, 
  # make them be the response string value
  def responses_for_category(category)
    response_keys_to_response_objects = response_objects_for_category(category)
    response_keys_to_response_objects.values.each do |values|
      values.map!(&:response_value)
    end
    response_keys_to_response_objects
  end

  def response_objects_for_category(category)
    # Find out which keys the Category is interested in
    keys_to_use = category.keys(school.collections)

    hash = responses_by_key.select { |k, v| keys_to_use.include? k }

    # Sort the data the same way the keys are sorted in the config
    sort_based_on_config hash, category
  end

  # Sort the data types the same way the keys are sorted in the config
  #
  def sort_based_on_config(data_key_to_results_hash, category)
    category_data_keys = category.keys(school.collections).map(&:downcase)
    # Sort the data types the same way the keys are sorted in the config
    Hash[
      data_key_to_results_hash.sort_by do |key, _|
        data_type_sort_num = category_data_keys.index(key.downcase)
        data_type_sort_num = 1 if data_type_sort_num.nil?
        data_type_sort_num
      end
    ]
  end

  def responses_by_key
    # since esp_response has multiple rows with the same key,
    # roll up all values for a key into an array
    all_responses.group_by(&:response_key)
  end

  def all_responses
    @all_responses ||=
      EspResponse.on_db(school.shard).where(school_id: school.id).active
  end
end

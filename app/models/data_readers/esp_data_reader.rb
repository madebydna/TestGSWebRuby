class EspDataReader < SchoolProfileDataReader

  def data_for_category(category)
    esp_responses = school.esp_responses

    # Find out which keys the Category is interested in
    keys_to_use = category.keys(school.collections)
    keys_and_labels = category.key_label_map

    # We grabbed all the school's data, so we need to filter out rows that dont have the keys that we need
    data = esp_responses.select { |response| keys_to_use.include? response.response_key}

    unless data.nil?
      # since esp_response has multiple rows with the same key, roll up all values for a key into an array
      responses_per_key = data.group_by(&:response_key)

      # Sort the data the same way the keys are sorted in the config
      responses_per_key = Hash[responses_per_key.sort_by { |key, value| keys_to_use.index(key) }]

      # Instead of the hash values being EspResponse objects, make them be the response value
      responses_per_key.values.each { |values| values.map!(&:response_value) }

      # Next, we want to transform the response keys and values into their "pretty" versions
      # The order in which we do this is important. The pretty labels for response_values are sometimes broken down
      # by response_key, and the response_keys used are the "raw" unprettified versions. If we transform the keys
      # first, the values won't transform correctly

      # First, get hash of response value string to ResponseValue
      lookup_table = ResponseValue.lookup_table

      # Transform the values
      responses_per_key.each do |key, values|
        values.map! do |value|
          lookup_value = lookup_table[[key, value]]
          if lookup_value.nil?
            value
          else
            lookup_value
          end
        end
      end

      # Originally we were making esp_response return a simple hash of key value pairs. But due to a requirement
      # We need to return an array of hashes, where each hash has a key, label, and value(s). This is because
      # we want to support multiple items with the same label. An array of 2-element arrays would work, but this is more
      # flexible
      array_of_hashes = []

      responses_per_key.each do |key, values|
        label = keys_and_labels[key]
        array_of_hashes << {
          key: key,
          label: label,
          value: values
        }
      end

      array_of_hashes
    end
  end
end

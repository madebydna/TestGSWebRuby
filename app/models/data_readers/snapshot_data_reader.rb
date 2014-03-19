class SnapshotDataReader < SchoolProfileDataReader

  def data_for_category(category)
    snapshot_results = []
    data_for_all_sources = {}

    #TODO move this into its own table when the keys and values are final
    key_filters = {enrollment: {level_codes: ['p', 'e', 'm', 'h'], school_types: ['public', 'charter', 'private'], source:'census_data_points' },
                   hours: {level_codes: ['p', 'e', 'm', 'h'], school_types: ['public', 'charter', 'private'], source: 'esp_data_points'},
                   :"head official name" => {level_codes: ['p', 'e', 'm', 'h'], school_types: ['public', 'charter', 'private'], source: 'census_data_points' },
                   transportation: {level_codes: ['p', 'e', 'm', 'h'], school_types: ['public', 'charter', 'private'], source: 'esp_data_points'},
                   capacity: {level_codes: ['p'], school_types: ['public', 'charter', 'private'], source: 'census_data_points'},
                   before_care: {level_codes: ['e', 'm'], school_types: ['public', 'charter', 'private'], source: 'esp_data_points'},
                   after_care: {level_codes: ['e', 'm'], school_types: ['public', 'charter', 'private'], source: 'esp_data_points'},
                   district: {level_codes: ['p', 'e', 'm', 'h'], school_types: ['public', 'charter'], source: 'school_data'},
                   school_type_affiliation: {level_codes: ['p', 'e', 'm', 'h'], school_types: ['private'], source: 'esp_data_points'}
    }

    #Construct the map to hold the data for every source type.
    key_filters.each_key { |key|
      source = key_filters[key.to_sym][:source]
      data_for_all_sources[source.to_sym] = ''
    }

    #Get the data for all the sources.
    data_for_all_sources.each_key do |source|
      data_for_all_sources[source.to_sym] = school.send(source.to_sym, category)
    end

    #Get the data points that should be displayed for the school collection.
    all_category_data =  category.category_data(school.collections)

    all_category_data.each do  |category_data|
      key = category_data.response_key
      #default value
      value = 'no info'
      #Get the labels for the response keys from the category_data table.
      label = category_data.label.nil? ? key : category_data.label

      #Filter out the keys based on level codes and school type
      show_data_for_key = false
      if school.type.present? && key_filters[key.to_sym].present? &&(key_filters[key.to_sym][:school_types].include? school.type) && !school.level_codes.blank?
        school.level_codes.each do |level_code|
          if key_filters[key.to_sym][:level_codes].include? level_code
            show_data_for_key = true
          end
        end
      end

      if (show_data_for_key)
        #get the source for the response key
        source = key_filters[key.to_sym][:source]
        if source.present?
          #Get the data for the source.
          data_for_source = data_for_all_sources[source.to_sym]

          if data_for_source.present? && data_for_source.any? && data_for_source[key].present?
            #esp_data_points returns an array and census_data_points does not return an array. Therefore cast everything
            #to an array and read the first value.
            value = Array(data_for_source[key]).first
          end
          snapshot_results << {key => {school_value: value, label: label}}
        end
      end
    end
    snapshot_results
  end

  def school_data
    hash = {}
    hash['district'] = school.district.name if school.district.present?
    hash['type'] = school.subtype
    hash
  end



end
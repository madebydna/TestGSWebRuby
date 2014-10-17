class SnapshotDataReader < SchoolProfileDataReader

  def data_for_category(category)
    snapshot_results = []

    data_for_all_sources = self.data_for_all_sources_for_category(category)

    #Get the data points that should be displayed for the school collection.
    all_category_data =  category.category_data(school.collections)

    all_category_data.each do  |category_data|

      key = category_data.response_key
      #default value
      value = 'no info'
      #Get the labels for the response keys from the category_data table.
      label = category_data.label.nil? ? key : category_data.label

      #Special case the key to show up only in SF and oakland.Temporary fix till we make snapshot module configurable.
      next if(key == 'summer_program' && ((school.collection.blank?) || (!([4,5].include?(school.collection.id))) ))

      #Filter out the keys based on level codes and school type
      if should_show_data_for_key? key
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
          if value != 'no info'
            snapshot_results << {
              key => {
                school_value: value,
                label: label
              }
            }
          end
        end
      end
    end
    snapshot_results
  end

  #Filter out the keys based on level codes and school type
  def should_show_data_for_key?(key)
    return false unless key_filters[key.to_sym].present?

    filter_level_codes = key_filters[key.to_sym][:level_codes]
    filter_school_types = key_filters[key.to_sym][:school_types]

    show_data_for_key = true

    if filter_school_types.present? && ! filter_school_types.include?(school.type)
      show_data_for_key = false
    end

    if filter_level_codes.present? && (filter_level_codes & Array(school.level_codes)).empty?
      show_data_for_key = false
    end

    show_data_for_key
  end

  def data_for_all_sources_for_category(category)
    data_for_all_sources = {}

    #Construct the map to hold the data for every source type.
    key_filters.each_key { |key|
      source = key_filters[key.to_sym][:source]
      data_for_all_sources[source.to_sym] = ''
    }

    #Get the data for all the sources.
    data_for_all_sources.each_key do |source|
      data_for_all_sources[source.to_sym] = school.send(source.to_sym, category)
    end

    data_for_all_sources
  end

  def key_filters
    #TODO move this into its own table when the keys and values are final
    {
      enrollment: {
        level_codes: ['p', 'e', 'm', 'h'],
        school_types: ['public', 'charter', 'private'],
        source: 'census_data_points'
      },
      hours: {
        level_codes: ['p', 'e', 'm', 'h'],
        school_types: ['public', 'charter', 'private'],
        source: 'esp_data_points'
      },
      :'head official name' => {
        level_codes: ['p', 'e', 'm', 'h'],
        school_types: ['public', 'charter', 'private'],
        source: 'census_data_points'
      },
      transportation: {
        level_codes: ['p', 'e', 'm', 'h'],
        school_types: ['public', 'charter', 'private'],
        source: 'esp_data_points'
      },
      capacity: {
        level_codes: ['p'],
        school_types: ['public', 'charter', 'private'],
        source: 'census_data_points'
      },
      before_care: {
        level_codes: ['e', 'm'],
        school_types: ['public', 'charter', 'private'],
        source: 'esp_data_points'
      },
      after_care: {
        level_codes: ['e', 'm'],
        school_types: ['public', 'charter', 'private'],
        source: 'esp_data_points'
      },
      district: {
        level_codes: ['p', 'e', 'm', 'h'],
        school_types: ['public', 'charter'],
        source: 'school_data'
      },
      school_type_affiliation: {
        level_codes: ['p', 'e', 'm', 'h'],
        school_types: ['private'],
        source: 'esp_data_points'
      },
      summer_program: {
        level_codes: ['e', 'm'],
        source: 'esp_data_points'
      }
    }
  end

end
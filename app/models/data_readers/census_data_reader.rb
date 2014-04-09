# 
# Retrieves CensusData and builds hashes in various formats
# 
class CensusDataReader < SchoolProfileDataReader
  #############################################################################
  # Methods exposed to SchoolProfileData and meant to be consumable by the view

  public

  # Returns Hash of data type labels to array of result hashes
  #
  #    reader.data_for_category   #=> {
  #                                     "Effective Leaders" => [
  #                                       {
  #                                         :breakdown => nil,
  #                                         :school_value => 83.0,
  #                                         :district_value => nil,
  #                                         :state_value => nil,
  #                                         :source => 'CA Dept. of Education',
  #                                         :year => 2011
  #                                       }
  #                                     ],
  #                                   }
  #
  #    reader.data_for_category   #=> {
  #                                     "Ethnicity" => [
  #                                       {
  #                                         :breakdown => "White",
  #                                         :school_value => 42.1053,
  #                                         :district_value => nil,
  #                                         :state_value => 71.4284,
  #                                         :source => 'CA Dept. of Education',
  #                                         :year => 2011
  #                                       },
  #                                       {
  #                                         :breakdown => "African-American",
  #                                         :school_value => 42.1053,
  #                                         :district_value => nil,
  #                                         :state_value => 71.4284,
  #                                         :source => "CA Dept. of Education",
  #                                         :year => 2011
  #                                       }
  #                                     ],
  #                                   }
  def labels_to_hashes_map(category)
    @labels_to_hashes_map ||= {}
    @labels_to_hashes_map[category.id] ||= (
      # Get data for all data types
      all_data = raw_data_for_category category

      data_type_to_results_hash = all_data.group_by(&:data_type)

      # If there's a data set with a null breakdown within a data type group,
      # remove the rows with non-null breakdowns
      data_type_to_results_hash = keep_null_breakdowns!(
        data_type_to_results_hash
      )

      # Sort the data types the same way the keys are sorted in the config
      data_type_to_results_hash = sort_based_on_config(
                                    data_type_to_results_hash,
                                    category
                                  )

      # Build a Hash that the view will consume
      data = build_data_type_descriptions_to_hashes_map(
        data_type_to_results_hash
      )

      # Replace strings within our Hash with human-readable versions
      prettify_hash data, category.key_label_map(school.collections)
    )
  end

  # Returns hash of data type descriptions to school values
  #
  #    reader.data_type_descriptions_to_school_values_map
  #                              #=> { "ethnicity" => 0.0,
  #                                    "enrollment" => 130.0,
  #                                    "head official name" => "LINDA BROOKS" }
  def data_type_descriptions_to_school_values_map
    results = raw_data || []

    results.each_with_object({}) do |census_data_set, hash|
      if census_data_set.school_value && census_data_set.data_type
        hash[census_data_set.data_type.downcase] = census_data_set.school_value
      end
    end
  end

  def footnotes_for_category(category)
    data = labels_to_hashes_map category
    sources = data.map do |key, values|
      if values && values.any?
        {
          source: values.first[:source],
          year: values.first[:year]
        }
      end
    end
    sources.compact.uniq
  end

  #############################################################################
  # Methods for actually building Hashes that view will consume

  protected

  # Returns Hash of data types to array of result hashes
  #
  # reader.build_hash_from_results({
  #  "Climate: Effective Leaders - Overall" => [
  #    +CensusDataSet+
  #      {
  #        :id => 176,
  #        :year => 2013,
  #        :grade => nil,
  #        :data_type_id => 237,
  #        :breakdown_id => nil,
  #        :active => 1,
  #        :level_code => "e,m,h",
  #        :subject_id => nil,
  #        :source => "CA Dept. of Education"
  #      }
  #  ]
  # })                          #=> "Climate: Effective Leaders - Overall" => [
  #                                     {
  #                                       :breakdown => nil,
  #                                       :school_value => 83.0,
  #                                       :district_value => nil,
  #                                       :state_value => nil,
  #                                       :source => "CA Dept. of Education",
  #                                       :year => 2011
  #                                     }
  #                                   ],
  #                                 }
  #
  def build_data_type_descriptions_to_hashes_map(data_type_to_results_hash)
    data = {}

    data_type_to_results_hash.each do |key, results|
      rows = results.map do |census_data_set|
        if census_data_set.state_value || census_data_set.school_value
          {
            breakdown: census_data_set.config_entry_breakdown_label ||
                       census_data_set.census_breakdown,
            school_value: census_data_set.school_value,
            district_value: census_data_set.district_value,
            state_value: census_data_set.state_value,
            source: census_data_set.source,
            year: census_data_set.year
          }
        end
      end.compact

      # Default the sort order of rows within a data type to school_value
      # descending School value might be nil, so sort using zero in that case
      rows.sort_by! do |row|
        row[:school_value] ? row[:school_value].to_f : 0.0
      end
      rows.reverse!

      data[key] = rows
    end

    data
  end

  # Creates a new human-readable +Hash+ from an existing hash by overwriting
  # strings with the correct labels
  #
  # reader.prettify_hash({
  #   "Climate: Effective Leaders - Overall" => [
  #      {
  #       :breakdown => nil,
  #       :school_value => 83.0,
  #       :district_value => nil,
  #       :state_value => nil
  #     }
  #   ]
  # })                                #=> "Effective Leaders - Overall" => [
  #                                           {
  #                                             :breakdown => nil,
  #                                             :school_value => 83.0,
  #                                             :district_value => nil,
  #                                             :state_value => nil
  #                                           }
  #                                         ],
  #                                       }
  #
  def prettify_hash(data_type_to_results_hash, key_label_map)
    data = {}
    data_type_to_results_hash.each do |key, results|
      label = key_label_map.fetch(key, key)
      label = key if label.blank?
      data[label] = results
    end

    data
  end

  # If there's a data set with a null breakdown within a data type group,
  # remove the rows with non-null breakdowns
  #
  def keep_null_breakdowns!(data_type_to_results_hash)
    data_type_to_results_hash.each_pair do |data_type, results|
      if results.any? { |result| result.breakdown_id.nil? }
        results.select! { |result| result.breakdown_id.nil? }
      end
    end
  end

  # Sort the data types the same way the keys are sorted in the config
  #
  def sort_based_on_config(data_type_to_results_hash, category)
    category_data_types = category.keys(school.collections).map(&:downcase)
    # Sort the data types the same way the keys are sorted in the config
    Hash[
      data_type_to_results_hash.sort_by do |data_type_desc, _|
        data_type_sort_num = category_data_types.index(data_type_desc.downcase)
        data_type_sort_num = 1 if data_type_sort_num.nil?
        data_type_sort_num
      end
    ]
  end

  ############################################################################
  # Methods for actually retrieving raw data. The "data reader" portion of this
  # class

  def raw_data
    @all_census_data ||= nil
    return @all_census_data if @all_census_data

    configured_data_types = Category.all_configured_keys 'census_data'

    # Get data for all data types
    @all_census_data = CensusDataForSchoolQuery.new(school)
                        .latest_data_for_school configured_data_types
  end

  def raw_data_for_category(category)
    category_data_types = category.keys(school.collections)
    raw_data.for_data_types category_data_types
  end
end

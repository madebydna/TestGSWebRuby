# encoding: utf-8

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

      results_array = []

      category_datas = category.category_data.sort_by do |cd|
        position = cd.sort_order
        position = 1 if position.nil?
        position
      end
      category_datas.each do |cd|
        matching_data_sets = all_data.select do |ds|
          data_set_matches_category_data_criteria(cd, ds)
        end

        matching_data_sets.each do |matching_data_set|
          data_set_hash = CensusDataSetJsonView.new(matching_data_set).to_hash
          next if data_set_hash.nil?

          # Add human-readable labels
          data_set_hash[:label] = cd.computed_label.gs_capitalize_first
          data_set_hash[:data_type_id] = matching_data_set.data_type_id
          results_array << data_set_hash
        end

      end

      results_array.compact!
      # TODO: Remove this and return an array instead.
      # Requires reconfiguring some data in the profile's admin tool,
      # So adding this temporarily
      results_array.group_by { |hash| hash[:label] }
    )
  end

  def data_set_matches_category_data_criteria(category_data, data_set)
    # Hack: Enforce that a census_data_config_entry exist for only census
    if category_data.response_key == 9 && !data_set.has_config_entry?
      return false
    end

    (category_data.response_key == data_set.data_type_id ||
      category_data.response_key.to_s.match(/#{data_set.data_type}/i)) &&
    category_data.subject_id == data_set.subject_id
  end

  def label_lookup_table(category)
    CensusDataType.lookup_table
      .merge(
        category.key_label_map(school.collections)
      )
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
      rows =
        results.map { |data_set| CensusDataSetJsonView.new(data_set).to_hash }
        .compact

      data[key] = rows
    end

    data
  end

  ############################################################################
  # Methods for actually retrieving raw data. The "data reader" portion of this
  # class

  def census_data_by_data_type_query
    configured_data_types =
      Array.wrap(page.all_configured_keys('census_data')) +
      Array.wrap(page.all_configured_keys('census_data_points'))

    CensusDataSetQuery.new(school.state)
      .with_data_types(configured_data_types)
      .with_school_values(school.id)
      .with_district_values(school.district_id)
      .with_state_values
      .with_census_descriptions(school.type)
  end

  def raw_data
    @all_census_data ||= nil
    return @all_census_data if @all_census_data

    # Get data for all data types
    results = census_data_by_data_type_query.to_a

    @all_census_data =
      CensusDataResults.new(results)
        .filter_to_max_year_per_data_type!
        .keep_null_breakdowns!
        .sort_school_value_desc_by_date_type!
  end

  def raw_data_for_category(category)
    category_data_types = category.keys(school.collections)
    raw_data.for_data_types category_data_types
  end
end

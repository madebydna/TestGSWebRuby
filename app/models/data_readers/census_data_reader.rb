# encoding: utf-8

#
# Retrieves CensusData and builds hashes in various formats
#
class CensusDataReader < SchoolProfileDataReader
  include CachedCategoryDataConcerns

  SCHOOL_CACHE_KEYS = ['characteristics']

  #############################################################################
  # Methods exposed to SchoolProfileData and meant to be consumable by the view

  public

  def school_cache_keys
    SCHOOL_CACHE_KEYS
  end

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
      all_data = cached_data_for_category(category, false)

      results_hash = {}

      category.category_datas.each do |cd|
        # Filter by data type
        data_for_data_type = all_data.select { |data_type_arr, _| data_type_matches_category_data?(cd, data_type_arr.first) }

        next if data_for_data_type.values.empty?

        data_for_data_type.each_pair do |data_type,data|
          data_for_data_type[data_type] = data.deep_dup
        end

      # Filter by subject
      data_for_data_type.values.first.select! do |data|
        (
        cd.subject_id == data[:subject] ||
          cd.subject_id == convert_subject_to_id(data[:subject])
        )
      end

        data_for_data_type.values.first.each do |data_set_hash|
          next if data_set_hash.nil?

            # Add human-readable labels
            data_set_hash[:label] = cd.computed_label.gs_capitalize_first
            data_set_hash[:description] = cd.computed_description(school.state)
        end

        data_for_data_type.each_pair do |data_type,value|

          if results_hash.has_key?(data_type) && value.is_a?(Array)
            results_hash[data_type] += value
          else
            results_hash[data_type] = value
          end
        end

      end

     results_hash
    )
  end

  def data_type_matches_category_data?(category_data, data_type)
    data_type = CensusDataType.data_type_id_for_data_type_label(data_type) if category_data.response_key.is_a? Numeric
    category_data.response_key == data_type || (
      data_type.present? && !!category_data.response_key.to_s.match(/#{Regexp.escape(data_type.to_s)}/i)
    )
  end

  def data_set_matches_category_data_criteria(category_data, data_set)
    # Hack: Enforce that a census_data_config_entry exist for only census
    # if category_data.response_key == 9 && !data_set.has_config_entry?
    #   return false
    # end

    (
      category_data.response_key == data_set ||
      category_data.response_key.to_s.match(/#{data_set}/i) ||
      category_data.response_key == CensusDataType.data_type_id_for_data_type_label(data_set) ||
      category_data.response_key.to_s.match(/#{CensusDataType.data_type_id_for_data_type_label(data_set)}/i)
    ) &&
    (
      category_data.subject_id.nil? || 
      category_data.subject_id == data_set[:subject] ||
      category_data.subject_id == convert_subject_to_id(data_set[:subject])
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

  def all_raw_data(specified_data_types=nil)
    results = raw_data(specified_data_types) || []
    results
  end

  ############################################################################
  # Methods for actually retrieving raw data. The "data reader" portion of this
  # class

  def census_data_by_data_type_query(specified_data_types=nil)
    specified_data_types ||=
      Array.wrap(page.all_configured_keys('census_data')) +
      Array.wrap(page.all_configured_keys('census_data_points'))

    CensusDataSetQuery.new(school.state)
      .with_data_types(specified_data_types)
      .with_school_values(school.id)
      .with_district_values(school.district_id)
      .with_state_values
      .with_census_descriptions(school.type)
  end

  def raw_data(specified_data_types=nil)
    @all_census_data ||= nil
    return @all_census_data if @all_census_data

    # Get data for all data types
    results = census_data_by_data_type_query(specified_data_types).to_a

    @all_census_data =
      CensusDataResults.new(results)
        .filter_to_max_year_per_data_type!
        .sort_school_value_desc_by_date_type!
  end
end

require 'table_data'
require 'hash_utils'

class CategoryDataReader
  include SchoolCategoryDataCacher

  def self.esp_response(school, category)
    esp_responses = EspResponse.on_db(school.shard).where(school_id: school.id).active

    # Find out which keys the Category is interested in
    keys_to_use = category.keys(school.collections)
    keys_and_labels = category.key_label_map

    # We grabbed all the school's data, so we need to filter out rows that dont have the keys that we need
    data = esp_responses.select! { |response| keys_to_use.include? response.response_key}

    unless data.nil?
      # since esp_response has multiple rows with the same key, roll up all values for a key into an array
      responses_per_key = data.group_by(&:response_key)

      # Sort the data the same way the keys are sorted in the config
      responses_per_key = Hash[responses_per_key.sort_by { |key, value| keys_to_use.index(key) }]

      # Instead of the hash values being EspResponse objects, make them be the response value
      responses_per_key.values.each { |values| values.map!(&:response_value) }

      # Look up all keys and values in a lookup table. Replace the key or value if there's a match in the lookup table
      lookup_table = ResponseValue.lookup_table(school.collections)
      responses_per_key.gs_rename_keys! { |key| keys_and_labels[key] || key }
      responses_per_key.gs_transform_values! { |value| lookup_table[value] || value }

      responses_per_key
    end
  end

  def self.dummy(school, _)
    return {dummy:true}
  end

  def self.details(school, category)
    data_details = esp_data_points(school, category);

    details_response_keys = {
        art: ['arts_media', 'arts_music', 'arts_performing_written', 'arts_visual'],
        sport: ['girls_sports', 'boys_sports'],
        club: ['student_clubs'],
        lang: ['foreign_language']
    }

     #need icon sprite size and name.  subtitle w color.  content
    return_counts_details = {
        art:   {count: '-', sprite: 'art', color: '#37BFBB', content: 'Arts & music'},
        sport: {count: '-', sprite: 'sports', color: '#5EC5DB', content: 'Sports'},
        club:  {count: '-', sprite: 'clubs', color: '#376592', content: 'Clubs'},
        lang:  {count: '-', sprite: 'language', color: '#A62019', content: 'Foreign languages'},
        sched: {count: 'Half day', sprite: 'schedule', color: '#9BB149', content: 'Preschool schedule'},
        commu: {count: 'Community center', sprite: 'community', color: '#E67E22', content: 'Care setting'}
    }

    # loop through details and handle total count for 0, infinity cases
    #  zero is a dash -
    #  check if value for all is none
    #  don't add none to count
    details_response_keys.keys.each do |osp_key|
       return_counts_details[osp_key][:count] = details_response_keys[osp_key].sum do | key |
          (Array(data_details[key]).count{|item| item.downcase != "none"})
       end
       if return_counts_details[osp_key][:count] == 0
          none_count = details_response_keys[osp_key].sum do | key |
            (Array(data_details[key]).count{|item| item.downcase == "none"})
          end
          return_counts_details[osp_key][:count] = none_count == 0 ?  "-" : 0
       end
    end
    return_counts_details
  end



  def self.esp_data_points(school, _)
    data = EspResponse.on_db(school.shard).where(school_id: school.id).active

    unless data.nil?
      # since esp_response has multiple rows with the same key, roll up all values for a key into an array
      responses_per_key = data.group_by(&:response_key)
      responses_per_key.values.each { |values| values.map!(&:response_value) }
    end

    #Merge start_time and end_time into hours.
    HashUtils.merge_keys responses_per_key, 'start_time', 'end_time', 'hours' do |value1 ,value2|
      value1.first.to_s + ' - ' + value2.first.to_s
    end

    #Split before_after_care into before_care and after_care.
    HashUtils.split_keys responses_per_key, 'before_after_care' do |value|
      result_hash = {}
      if value.kind_of?(Array)
        value.each do |val|
          result_hash[val.downcase  + "_care"] =  val.downcase  unless val.nil?
        end
      end
      result_hash
    end

    responses_per_key
  end

  def self.enrollment(school, _)

    results = CensusDataForSchoolQuery.new(school)
    .data_for_school
    .filter_to_max_year_per_data_type!(school.state)
    .for_data_type!('enrollment')

    if results && results.any?
      results.first.school_value
    end

  end

  def self.census_data_points(school, _)
    results = CensusDataForSchoolQuery.new(school)
    .data_for_school
    .filter_to_max_year_per_data_type!(school.state)

    results ||= []

    results_hash = {}

    results.each do |census_data_set|
      if census_data_set.school_value
        results_hash[census_data_set.data_type.downcase] = census_data_set.school_value
      end
    end

    results_hash
  end

  def self.student_ethnicity(school, _)

    results = CensusDataForSchoolQuery.new(school)
      .latest_data_for_school
      .for_data_type!('ethnicity')

    results ||= []

    rows = results.map do |census_data_set|
      if census_data_set.state_value && census_data_set.school_value
        {
            ethnicity: census_data_set.census_breakdown,
            school_value: census_data_set.school_value.round,
            state_value: census_data_set.state_value.round
        }
      end
    end.compact

    rows.sort_by! { |row| row[:school_value] }.reverse!

    if rows.any?
      rows
    else
      nil
    end
  end

  # This method will return all of the various data keys that are configured to display for a certain *source*
  # This works by aggregating all of the CategoryData keys for Categories which use this source
  # For example, if both the "Ethnicity" category and "Details" category use a source called "census_data", then
  # this method would return all the keys configured for both Ethnicity and Details
  def self.all_configured_keys(source = caller[0][/`.*'/][1..-2])

    Rails.cache.fetch("all_configured_keys/#{source}", expires_in: 1.hour) do
      categories_using_source = Category.where(source: source).all

      all_keys = []
      categories_using_source.each{ |category| all_keys += category.keys }

      # Add in keys where source is specified in CategoryData
      all_keys += CategoryData.where(source: source).pluck(:response_key)
    end
  end

  def self.census_data(school, category)
    all_configured_data_types = all_configured_keys

    # Get data for all data types
    results = CensusDataForSchoolQuery.new(school).latest_data_for_school all_configured_data_types

    # Get the data types that this category needs. These come sorted based on sort_order
    data_types = category.keys(school.collections)

    # Filter data: return only data for this category's chosen data types
    results.for_data_types! data_types

    data_type_to_results_map = results.group_by(&:data_type)

    # Sort the data types the same way the keys are sorted in the config
    data_type_to_results_map = Hash[data_type_to_results_map.sort_by {
        |data_type_desc, value| data_types.index(data_type_desc.downcase)
    }]

    data = {}

    data_type_to_results_map.each do |key, results|
      rows = results.map do |census_data_set|
        if census_data_set.state_value || census_data_set.school_value
          {
              breakdown: census_data_set.census_breakdown,
              school_value: census_data_set.school_value,
              district_value: census_data_set.district_value,
              state_value: census_data_set.state_value
          }
        end
      end.compact

      # Default the sort order of rows within a data type to school_value descending
      rows.sort_by! { |row| row[:school_value] }.reverse!

      data[key] = rows
    end

    data
  end

  def self.test_scores(school, _)
    school.test_scores
  end

  def self.school_data(school, _)
    hash = {}
    hash['district'] = school.district.name if school.district.present?
    hash['type']= school.subtype
    hash
  end

  def self.snapshot(school, category)
    snapshot_results = []
    data_for_all_sources = {}

    #TODO move this into its own table when the keys and values are final
    key_filters = {enrollment: {level_codes: ['p', 'e', 'm', 'h'], school_types: ['public', 'charter', 'private'], format: 'value_integer',source:'census_data_points' },
                   hours: {level_codes: ['p', 'e', 'm', 'h'], school_types: ['public', 'charter', 'private'], source: 'esp_data_points'},
                   :"head official name" => {level_codes: ['p', 'e', 'm', 'h'], school_types: ['public', 'charter', 'private'], source: 'census_data_points' },
                   transportation: {level_codes: ['p', 'e', 'm', 'h'], school_types: ['public', 'charter', 'private'], source: 'esp_data_points'},
                   :"students per teacher" => {level_codes: ['p'], school_types: ['public', 'charter', 'private'], source: 'census_data_points'},
                   capacity: {level_codes: ['p'], school_types: ['public', 'charter', 'private'], source: 'census_data_points'},
                   before_care: {level_codes: ['e', 'm'], school_types: ['public', 'charter', 'private'], source: 'esp_data_points'},
                   after_care: {level_codes: ['e', 'm'], school_types: ['public', 'charter', 'private'], source: 'esp_data_points'},
                   district: {level_codes: ['p', 'e', 'm', 'h'], school_types: ['public', 'charter'], source: 'school_data'},
                   type: {level_codes: ['p', 'e', 'm', 'h'], school_types: ['private'], source: 'school_data'}
    }

    #Construct the map to hold the data for every source type.
    key_filters.each_key { |key|
      source = key_filters[key.to_sym][:source]
      data_for_all_sources[source.to_sym] = ''
    }

    #Get the data for all the sources.
    data_for_all_sources.each_key do |source|
      data_for_all_sources[source.to_sym] = self.send(source.to_sym, school, category)
    end

    #Get all the keys for the school and category.
    all_snapshot_keys = category.category_data(school.collections).map(&:response_key)

    #Get the labels for the response keys from the ResponseValue table.
    lookup_table_for_labels = ResponseValue.lookup_table(category)

    all_snapshot_keys.each do  |key|

      #Filter out the keys based on level codes and school type
      show_data_for_key = false
      if school.type.present? && (key_filters[key.to_sym][:school_types].include? school.type) && !school.level_codes.blank?
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
          if data_for_source.present? && data_for_source.any?

            #esp_data_points returns an array and census_data_points does not return an array. Therefore cast everything
            #to an array and read the first value.
            value = data_for_source[key].present? ? Array(data_for_source[key]).first : 'N/A'

            #Get the labels for the response keys from the ResponseValue table.
            label = lookup_table_for_labels[key] || key

            snapshot_results << {key => {school_value: value, label: label}}
          end
        end
      end

    end
    snapshot_results
  end

  def self.sources
    methods(false) - [:key, :cache_methods, :all_configured_keys, :sources]
  end

  def self.rating_data (school, _)
    #Get the ratings from the database.
    results = fetch_rating_results school

    #Get the data type ids for the city,state and GS ratings.
    city_rating_data_type_ids = fetch_city_rating_data_type_ids school
    state_rating_data_type_ids = fetch_state_rating_data_type_ids school
    gs_rating_data_type_ids = fetch_gs_rating_data_type_ids

    #Loop up table for rating descriptions.
    description_hash = DataDescription.lookup_table

    #Build a hash to hold the ratings results.
    ratings_data = {}

    #Put that overall GS rating and description in the hash, since the overall GS rating is read from the metadata table.
    ratings_data["gs_rating"] = {"overall_rating" => school.school_metadata.overallRating}
    if !RatingsConfiguration.gs_rating_configuration.nil? && !RatingsConfiguration.gs_rating_configuration.overall.nil?
      ratings_data["gs_rating"]["description"] =  description_hash[RatingsConfiguration.gs_rating_configuration.overall.description_key]
    end

    #Loop over the results and construct the ratings data hash
    results.each do |result|
      if (state_rating_data_type_ids.include? result.data_type_id)
        construct_state_ratings ratings_data,  result, school
      elsif city_rating_data_type_ids.include? result.data_type_id
        construct_city_ratings ratings_data, result, school
      elsif gs_rating_data_type_ids.include? result.data_type_id then
        construct_GS_ratings ratings_data, result
      end

    end
    ratings_data
  end

  def self.construct_state_ratings ratings_data,test_data_set, school
    state_rating_configuration = RatingsConfiguration.state_rating_configuration[school.shard.to_s]
    #Build a hash of the data_keys to the rating descriptions.
    description_hash = DataDescription.lookup_table
    ratings_data["state_rating"] = {"overall_rating" => test_data_set.school_value_text,
                                    "description" => description_hash[state_rating_configuration.overall.description_key]}
  end

  def self.construct_city_ratings ratings_data, test_data_set, school
    city_rating_configuration = city_rating_config_exists?(school) ? RatingsConfiguration.city_rating_configuration[school.shard.to_s][school.city] : nil
    #Build a hash of the data_keys to the rating descriptions.
    description_hash = DataDescription.lookup_table
    city_rating_hash = ratings_data["city_rating"].nil? ? {} : ratings_data["city_rating"]
    #Nested hash to hold the rating breakdowns.
    city_sub_rating_hash = city_rating_hash["rating_breakdowns"].nil? ? {} : city_rating_hash["rating_breakdowns"]
    #Put the overall city rating in the results.
    if test_data_set.data_type_id == city_rating_configuration.overall.data_type_id
      city_rating_hash["overall_rating"] = test_data_set.school_value_text
    end
    city_rating_hash["description"] = description_hash[city_rating_configuration.overall.description_key]
    #City rating label in the results
    city_rating_hash["city_rating_label"] = test_data_set.display_name

    #Loop over the configuration to put the ratings breakdowns in the results.
    city_rating_configuration.rating_breakdowns.each do |key, config|
      if (test_data_set.data_type_id == config.data_type_id && (!test_data_set.school_value_text.nil?))
        city_sub_rating_hash[config.label] = test_data_set.school_value_text
      end
    end
    ratings_data["city_rating"] = city_rating_hash
    if city_sub_rating_hash.any?
      ratings_data["city_rating"]["rating_breakdowns"] = city_sub_rating_hash
    end
  end

  def self.construct_GS_ratings ratings_data, test_data_set
    #The gs ratings hash is construct above when adding the gs rating.
    gs_rating_hash = ratings_data["gs_rating"]
    #Nested hash to hold the rating breakdowns.
    gs_sub_rating_hash = gs_rating_hash["rating_breakdowns"].nil? ? {} : gs_rating_hash["rating_breakdowns"]

    #Loop over the configuration to put the ratings breakdowns in the results.
    RatingsConfiguration.gs_rating_configuration.rating_breakdowns.each do |key, config|
      if (test_data_set.data_type_id == config.data_type_id && (!test_data_set.school_value_float.nil?))
        gs_sub_rating_hash[config.label] = test_data_set.school_value_float.round
      end
    end
    ratings_data["gs_rating"] = gs_rating_hash
    if gs_sub_rating_hash.any?
      ratings_data["gs_rating"]["rating_breakdowns"] = gs_sub_rating_hash
    end
  end

  def self.fetch_rating_results school
    #Build an array of all the data type ids so that we can query the database only once.
    all_data_type_ids = fetch_city_rating_data_type_ids(school) + fetch_state_rating_data_type_ids(school) + fetch_gs_rating_data_type_ids

    #Get the ratings from the database.
    TestDataSet.by_data_type_ids(school, all_data_type_ids)
  end

  def self.fetch_state_rating_data_type_ids school
    state_rating_configuration = RatingsConfiguration.state_rating_configuration[school.shard.to_s]
    state_rating_configuration.nil? ? [] : Array(state_rating_configuration.overall.data_type_id)
  end

  def self.fetch_gs_rating_data_type_ids
    gs_rating_configuration = RatingsConfiguration.gs_rating_configuration
    gs_rating_configuration.nil? ? [] : gs_rating_configuration.rating_breakdowns.values.map(&:data_type_id)
  end

  def self.fetch_city_rating_data_type_ids school
    city_rating_configuration = city_rating_config_exists?(school) ? RatingsConfiguration.city_rating_configuration[school.shard.to_s][school.city] : nil
    city_rating_configuration.nil? ? [] : city_rating_configuration.rating_breakdowns.values.map(&:data_type_id) + Array(city_rating_configuration.overall.data_type_id)
  end

  def self.city_rating_config_exists? school
    !RatingsConfiguration.city_rating_configuration[school.shard.to_s].nil? && !RatingsConfiguration.city_rating_configuration[school.shard.to_s][school.city].nil?
  end

  def self.state_rating_config_exists? school
    !RatingsConfiguration.city_rating_configuration[school.shard.to_s].nil?
  end

  #cache_methods :student_ethnicity, :test_scores, :enrollment, :esp_response, :census_data_points, :esp_data_points, :snapshot
end

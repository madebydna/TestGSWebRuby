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

      # Next, we want to transform the response keys and values into their "pretty" versions
      # The order in which we do this is important. The pretty labels for response_values are sometimes broken down
      # by response_key, and the response_keys used are the "raw" unprettified versions. If we transform the keys
      # first, the values won't transform correctly

      # First, get hash of response value string to ResponseValue
      lookup_table = ResponseValue.lookup_table(school.collections)

      # Transform the values
      responses_per_key.each do |key, values|
        values.map! do |value|
          lookup_value = lookup_table[value]
          if lookup_value.nil? || (lookup_value[:response_key].present? && lookup_value[:response_key] != key)
            value
          else
            lookup_value[:response_label]
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

        art:   {count: 'n/a', content: 'Arts & music'},
        sport: {count: 'n/a', content: 'Sports'},
        club:  {count: 'n/a', content: 'Clubs'},
        lang:  {count: 'n/a', content: 'Foreign languages'},
        sched: {count: 'Half day', content: 'Preschool schedule'},
        commu: {count: 'Community center', content: 'Care setting'}
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
          return_counts_details[osp_key][:count] = none_count == 0 ?  "n/a" : 0
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
    results = RatingsHelper.fetch_ratings_for_school school

    #Build a hash to hold the ratings results.
    {"gs_rating" => (RatingsHelper.construct_GS_ratings results, school),
                    "city_rating" => (RatingsHelper.construct_city_ratings results, school),
                    "state_rating" => (RatingsHelper.construct_state_ratings results, school)
    }
  end




  #cache_methods :student_ethnicity, :test_scores, :enrollment, :esp_response, :census_data_points, :esp_data_points, :snapshot
end

class RatingsHelper

  attr_accessor :ratings_config, :results

  def initialize(results,ratings_config)
    @ratings_config = ratings_config
    @results = results
  end

  def construct_state_ratings
    state_rating_configuration = ratings_config.state_rating_configuration
    state_rating_data_type_ids = ratings_config.state_rating_data_type_ids

    #Hash to hold the state ratings results
    state_ratings_results = {}

    #Build a hash of the data_keys to the rating descriptions.
    description_hash = DataDescription.lookup_table

    #If configuration exists then loop over the results
    results.each do |test_data_set|
      if (state_rating_data_type_ids.include? test_data_set.data_type_id)
        #Build a hash of the data_keys to the rating descriptions.
        state_ratings_results = {'overall_rating' => test_data_set.school_value_text,
                                 'description' => description_hash[state_rating_configuration['overall']['description_key']]}
        break
      end
    end
    state_ratings_results
  end

  def construct_city_ratings(school)

    city_rating_configuration = ratings_config.city_rating_configuration
    city_rating_data_type_ids = ratings_config.city_rating_data_type_ids

    return {} if city_rating_configuration.nil? || city_rating_data_type_ids.empty?

    #Hash to hold the city ratings results
    city_ratings_results = {}
    #Nested hash to hold the rating breakdowns.
    city_sub_rating_hash = {}

    #Build a hash of the data_keys to the rating descriptions.
    description_hash = DataDescription.lookup_table

    #Loop over the results
    results.each do |test_data_set|
      if (city_rating_data_type_ids.include? test_data_set.data_type_id)

        if test_data_set.data_type_id == city_rating_configuration['overall']['data_type_id']
          city_ratings_results['overall_rating'] = test_data_set.school_value_text
          city_ratings_results['description'] = description_hash[city_rating_configuration['overall']['description_key']]
          city_ratings_results['city_rating_label'] = test_data_set.display_name
        else

          #Loop over the configuration to put the ratings breakdowns in the results.
          city_rating_configuration['rating_breakdowns'].each do |key, config|
            if (test_data_set.data_type_id == config['data_type_id'] && (!test_data_set.school_value_text.nil?))
              city_sub_rating_hash[config['label']] = test_data_set.school_value_text
            end
          end
        end

      end
    end

    methodology_url = get_methodology_url(city_rating_configuration,school)
    #Only put the url if there is an overall rating.
    if city_ratings_results['overall_rating'] && methodology_url.present?
      city_ratings_results['methodology_url'] = methodology_url
    end

    #Only put the sub-ratings if there is an overall rating.
    if city_ratings_results['overall_rating'] && city_sub_rating_hash.any?
      city_ratings_results['rating_breakdowns'] = city_sub_rating_hash
    end

    city_ratings_results
  end


  def construct_GS_ratings(school)
    school_rating_value = school.school_metadata.overallRating
    return {} if school_rating_value.nil?

    gs_rating_configuration = ratings_config.gs_rating_configuration
    gs_rating_data_type_ids = ratings_config.gs_rating_data_type_ids

    #Build a hash of the data_keys to the rating descriptions.
    description_hash = DataDescription.lookup_table

    #Hash to hold the city ratings results
    gs_ratings_results ={}
    #Nested hash to hold the rating breakdowns.
    gs_sub_rating_hash ={}

    #Put that overall GS rating and description in the hash, since the overall GS rating is read from the metadata table.
    if school_rating_value.present? && gs_rating_configuration
      gs_ratings_results = {'overall_rating' => school_rating_value, 'description' => description_hash[gs_rating_configuration['overall']['description_key']]}
    end

    #If configuration exists then loop over the results
    if !gs_rating_data_type_ids.empty?
      results.each do |test_data_set|
        if (gs_rating_data_type_ids.include? test_data_set.data_type_id)

          #Loop over the configuration to put the ratings breakdowns in the results.
          gs_rating_configuration['rating_breakdowns'].each do |key, config|
            if (test_data_set.data_type_id == config['data_type_id'] && (!test_data_set.school_value_float.nil?))
              gs_sub_rating_hash[config['label']] = test_data_set.school_value_float.round
            end
          end
        end
      end
    end

    #Only put the sub-ratings if there is an overall rating.
    if school_rating_value.present? && gs_sub_rating_hash.any?
      gs_ratings_results['rating_breakdowns'] = gs_sub_rating_hash
    end

    gs_ratings_results
  end

  def construct_preK_ratings
    preK_rating_configuration = ratings_config.prek_rating_configuration
    preK_rating_data_type_ids = ratings_config.prek_rating_data_type_ids

    #Hash to hold the preK ratings results
    preK_ratings_results = {}

    #Build a hash of the data_keys to the rating descriptions.
    description_hash = DataDescription.lookup_table

    #If configuration exists then loop over the results
    if !preK_rating_configuration.nil? && !preK_rating_data_type_ids.empty?
      results.each do |test_data_set|
        if (preK_rating_data_type_ids.include? test_data_set.data_type_id)
          if preK_rating_configuration['star_rating'] && test_data_set.data_type_id == preK_rating_configuration['star_rating']['data_type_id']
            preK_ratings_results['star_rating'] = test_data_set.school_value_float.round
            preK_ratings_results['description'] = description_hash[preK_rating_configuration['star_rating']['description_key']]
            preK_ratings_results['preK_rating_label'] = test_data_set.display_name
          end
        end
      end
    end
    preK_ratings_results
  end

  def get_methodology_url(city_rating_configuration, school)
    methodology_url = ""
    return methodology_url if !city_rating_configuration || !city_rating_configuration['overall']

    if city_rating_configuration['overall']['methodology_url_key'].present?
      key = city_rating_configuration['overall']['methodology_url_key']
      if school.school_metadata[key.to_sym].present?
        methodology_url = school.school_metadata[key.to_sym]
      end
    end
    if methodology_url.blank? && city_rating_configuration['overall']['default_methodology_url'].present?
      methodology_url = city_rating_configuration['overall']['default_methodology_url']
    end
    methodology_url
  end

end

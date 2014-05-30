class RatingsHelper

  attr_accessor :ratings_config, :results

  def initialize(results,ratings_config)
    @ratings_config = ratings_config
    @results = results
  end

  [:state, :city].each do |var_name|
    method_name = "construct_#{var_name}_ratings".to_sym
    define_method method_name do |school|
      rating_configuration = ratings_config.send "#{var_name}_rating_configuration"
      rating_data_type_ids = ratings_config.send "#{var_name}_rating_data_type_ids"

      #Hash to hold the ratings results
      ratings_results = {}
      #Nested hash to hold the rating breakdowns.
      sub_rating_hash = {}

      #Build a hash of the data_keys to the rating descriptions.
      description_hash = DataDescription.lookup_table
      #If configuration exists then loop over the results
      results.each do |test_data_set|
        if ((rating_data_type_ids.include? test_data_set['data_type_id']))
          if test_data_set['data_type_id'] == rating_configuration['overall']['data_type_id']
            ratings_results['overall_rating'] = test_data_set['school_value_text']
            ratings_results['description'] = description_hash[[school.state.upcase,rating_configuration['overall']['description_key']]]
            ratings_results["#{var_name}_rating_label"] = rating_configuration['overall']['label']
          else
            #Loop over the configuration to put the ratings breakdowns in the results.
            rating_configuration['rating_breakdowns'].each do |key, config|
              if (test_data_set['data_type_id'] == config['data_type_id'] && (!test_data_set['school_value_text'].nil?))
                sub_rating_hash[config['label']] = test_data_set['school_value_text']
              end
            end
          end
        end
      end
      methodology_url = get_methodology_url(rating_configuration,school)

      #Only put the url if there is an overall rating.
      if ratings_results['overall_rating'] && methodology_url.present?
        ratings_results['methodology_url'] = methodology_url
      end

      #Only put the sub-ratings if there is an overall rating.
      if ratings_results['overall_rating'] && sub_rating_hash.any?
        ratings_results['rating_breakdowns'] = sub_rating_hash
      end

      ratings_results
    end
  end


  def construct_GS_ratings(school)
    school_rating_value = school.school_metadata.overallRating
    return {} if school_rating_value.nil?
    gs_rating_configuration = ratings_config.gs_rating_configuration
    gs_rating_data_type_ids = ratings_config.gs_rating_data_type_ids

    #Build a hash of the data_keys to the rating descriptions.
    description_hash = DataDescription.lookup_table

    #Hash to hold the gs ratings results
    gs_ratings_results ={}
    #Nested hash to hold the rating breakdowns.
    gs_sub_rating_hash ={}
    #Put that overall GS rating and description in the hash, since the overall GS rating is read from the metadata table.
    if school_rating_value.present? && gs_rating_configuration
      gs_ratings_results = {'overall_rating' => school_rating_value, 'description' => description_hash[[nil,gs_rating_configuration['overall']['description_key']]]}
    end

    #If configuration exists then loop over the results
    if !gs_rating_data_type_ids.empty?
      results.each do |test_data_set|
        if (gs_rating_data_type_ids.include? test_data_set['data_type_id'])
          #Loop over the configuration to put the ratings breakdowns in the results.
          gs_rating_configuration['rating_breakdowns'].each do |key, config|
            if (test_data_set['data_type_id'] == config['data_type_id'] && (!test_data_set['school_value_float'].nil?))

              res_hash = {'rating' => test_data_set['school_value_float'].round}

              #get the sub-rating descriptions
              sub_rating_description = get_sub_rating_descriptions(config, school, description_hash)
              res_hash['description'] = sub_rating_description if sub_rating_description.present?

              gs_sub_rating_hash[config['label']] = res_hash
            end
          end
        end
      end
    end

    #Only put the sub-ratings if there is an overall rating.
    if school_rating_value.present? && gs_sub_rating_hash.any?
      gs_ratings_results['rating_breakdowns'] = gs_sub_rating_hash
      gs_ratings_results.merge!('disclaimer_private' => description_hash[[school.state.upcase,'disclaimer_private']]) unless description_hash[[school.state.upcase,'disclaimer_private']].blank?
    end
    gs_ratings_results
  end

  def construct_preK_ratings(school)
    preK_rating_configuration = ratings_config.prek_rating_configuration
    preK_rating_data_type_ids = ratings_config.prek_rating_data_type_ids

    #Hash to hold the preK ratings results
    preK_ratings_results = {}

    #Build a hash of the data_keys to the rating descriptions.
    description_hash = DataDescription.lookup_table

    #If configuration exists then loop over the results
    if !preK_rating_configuration.nil? && !preK_rating_data_type_ids.empty?
      results.each do |test_data_set|
        if ((preK_rating_data_type_ids.include? test_data_set['data_type_id']) && !(test_data_set['school_value_float'].nil?))
          if preK_rating_configuration['star_rating'] && test_data_set['data_type_id'] == preK_rating_configuration['star_rating']['data_type_id']
            preK_ratings_results['star_rating'] = test_data_set['school_value_float'].round
            preK_ratings_results['description'] = description_hash[[school.state.upcase,preK_rating_configuration['star_rating']['description_key']]]
            preK_ratings_results['preK_rating_label'] = preK_rating_configuration['star_rating']['label']
          end
        end
      end
    end
    preK_ratings_results
  end

  def get_methodology_url(rating_configuration, school)
    methodology_url = ''
    return methodology_url if !rating_configuration || !rating_configuration['overall']

    if rating_configuration['overall']['methodology_url_key'].present?
      key = rating_configuration['overall']['methodology_url_key']
      if school.school_metadata[key.to_sym].present?
        methodology_url = school.school_metadata[key.to_sym]
      end
    end
    if methodology_url.blank? && rating_configuration['overall']['default_methodology_url'].present?
      methodology_url = rating_configuration['overall']['default_methodology_url']
    end
    methodology_url
  end

  def get_sub_rating_descriptions(gs_rating_configuration, school, description_hash)
    description = ''
    if gs_rating_configuration && gs_rating_configuration['description_key'].present?
      description << (description_hash[[nil, gs_rating_configuration['description_key']]] || '')
    end
    if gs_rating_configuration && gs_rating_configuration['footnote_key'].present?
      description << ' ' if description.present?
      footnote_description = description_hash[[school.state.upcase, gs_rating_configuration['footnote_key']]]
      description << footnote_description if footnote_description
    end
    description
  end

end

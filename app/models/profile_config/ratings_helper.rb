class RatingsHelper

  def self.fetch_ratings_for_school school
    #Build an array of all the data type ids so that we can query the database only once.
    all_data_type_ids = RatingsConfiguration.fetch_city_rating_data_type_ids(school) + RatingsConfiguration.fetch_state_rating_data_type_ids(school) + RatingsConfiguration.fetch_gs_rating_data_type_ids + RatingsConfiguration.fetch_preK_rating_data_type_ids(school)

    #Get the ratings from the database.
    TestDataSet.by_data_type_ids(school, all_data_type_ids)
  end

  def self.construct_state_ratings results, school
    state_rating_configuration = RatingsConfiguration.fetch_state_rating_configuration school
    state_rating_data_type_ids = RatingsConfiguration.fetch_state_rating_data_type_ids school

    #Hash to hold the state ratings results
    state_ratings_results = {}

    #Build a hash of the data_keys to the rating descriptions.
    description_hash = DataDescription.lookup_table

    #If configuration exists then loop over the results
    results.each do |test_data_set|
      if (state_rating_data_type_ids.include? test_data_set.data_type_id)
        #Build a hash of the data_keys to the rating descriptions.
        state_ratings_results = {"overall_rating" => test_data_set.school_value_text,
                                 "description" => description_hash[state_rating_configuration.overall.description_key]}
        break
      end
    end
    state_ratings_results
  end

  def self.construct_city_ratings results, school

    city_rating_configuration = RatingsConfiguration.fetch_city_rating_configuration school
    city_rating_data_type_ids = RatingsConfiguration.fetch_city_rating_data_type_ids school

    #Hash to hold the city ratings results
    city_ratings_results = {}
    #Nested hash to hold the rating breakdowns.
    city_sub_rating_hash = {}

    #Build a hash of the data_keys to the rating descriptions.
    description_hash = DataDescription.lookup_table

    #If configuration exists then loop over the results
    if !city_rating_configuration.nil? && !city_rating_data_type_ids.empty?
      results.each do |test_data_set|
        if (city_rating_data_type_ids.include? test_data_set.data_type_id)

          if test_data_set.data_type_id == city_rating_configuration.overall.data_type_id
            city_ratings_results["overall_rating"] = test_data_set.school_value_text
            city_ratings_results["description"] = description_hash[city_rating_configuration.overall.description_key]
            city_ratings_results["city_rating_label"] = test_data_set.display_name
          else

            #Loop over the configuration to put the ratings breakdowns in the results.
            city_rating_configuration.rating_breakdowns.each do |key, config|
              if (test_data_set.data_type_id == config.data_type_id && (!test_data_set.school_value_text.nil?))
                city_sub_rating_hash[config.label] = test_data_set.school_value_text
              end
            end
          end

        end
      end
    end

    #Only put the sub-ratings if there is an overall rating.
    if city_ratings_results['overall_rating'] && city_sub_rating_hash.any?
      city_ratings_results["rating_breakdowns"] = city_sub_rating_hash
    end

    city_ratings_results
  end


  def self.construct_GS_ratings results, school
    school_rating_value = school.school_metadata.overallRating
    return {} if school_rating_value.nil?

    gs_rating_configuration = RatingsConfiguration.fetch_gs_rating_configuration
    gs_rating_data_type_ids = RatingsConfiguration.fetch_gs_rating_data_type_ids

    #Build a hash of the data_keys to the rating descriptions.
    description_hash = DataDescription.lookup_table

    #Hash to hold the city ratings results
    gs_ratings_results ={}
    #Nested hash to hold the rating breakdowns.
    gs_sub_rating_hash ={}

    #Put that overall GS rating and description in the hash, since the overall GS rating is read from the metadata table.
    if school_rating_value.present?
      gs_ratings_results = {"overall_rating" => school_rating_value, "description" => description_hash[gs_rating_configuration.overall.description_key]}
    end

    #If configuration exists then loop over the results
    if !gs_rating_data_type_ids.empty?
      results.each do |test_data_set|
        if (gs_rating_data_type_ids.include? test_data_set.data_type_id)

          #Loop over the configuration to put the ratings breakdowns in the results.
          gs_rating_configuration.rating_breakdowns.each do |key, config|
            if (test_data_set.data_type_id == config.data_type_id && (!test_data_set.school_value_float.nil?))
              gs_sub_rating_hash[config.label] = test_data_set.school_value_float.round
            end
          end
        end
      end
    end

    #Only put the sub-ratings if there is an overall rating.
    if school_rating_value.present? && gs_sub_rating_hash.any?
      gs_ratings_results["rating_breakdowns"] = gs_sub_rating_hash
    end

    gs_ratings_results
  end

  def self.construct_preK_ratings results, school
    preK_rating_configuration = RatingsConfiguration.fetch_preK_rating_configuration(school)
    preK_rating_data_type_ids = RatingsConfiguration.fetch_preK_rating_data_type_ids(school)

    #Hash to hold the preK ratings results
    preK_ratings_results = {}

    #Build a hash of the data_keys to the rating descriptions.
    description_hash = DataDescription.lookup_table

    #If configuration exists then loop over the results
    if !preK_rating_configuration.nil? && !preK_rating_data_type_ids.empty?
      results.each do |test_data_set|
        if (preK_rating_data_type_ids.include? test_data_set.data_type_id)

          if preK_rating_configuration.star_rating && test_data_set.data_type_id == preK_rating_configuration.star_rating.data_type_id
            preK_ratings_results["star_rating"] = test_data_set.school_value_float.round
            preK_ratings_results["description"] = description_hash[preK_rating_configuration.star_rating.description_key]
            preK_ratings_results["preK_rating_label"] = test_data_set.display_name
          end
        end
      end
    end
    preK_ratings_results
  end
end

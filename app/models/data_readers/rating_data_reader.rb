class RatingDataReader < SchoolProfileDataReader

  def data
    #Get the ratings configuration from the database.
    ratings_config = RatingsConfiguration.configuration_for_school(school.state)

    #Build an array of all the data type ids so that we can query the database only once.
    all_data_type_ids = ratings_config.city_rating_data_type_ids + ratings_config.state_rating_data_type_ids + ratings_config.gs_rating_data_type_ids + ratings_config.prek_rating_data_type_ids

    #Get the ratings from the database.
    results = TestDataSet.by_data_type_ids(school, all_data_type_ids)

    ratings_helper = RatingsHelper.new(results,ratings_config)

    #Build a hash to hold the ratings results.
    gs_rating_value = ratings_helper.construct_GS_ratings(school)
    city_rating_value =  ratings_helper.construct_city_ratings(school)
    state_rating_value = ratings_helper.construct_state_ratings(school)
    preK_ratings = ratings_helper.construct_preK_ratings(school)

    return_var = {}
    if gs_rating_value.present?
      return_var["gs_rating"] = gs_rating_value
    end
    if city_rating_value.present?
      return_var["city_rating"] = city_rating_value
    end
    if state_rating_value.present?
      return_var["state_rating"] = state_rating_value
    end
    if preK_ratings.present?
      return_var["preK_ratings"] = preK_ratings
    end

    return_var
  end

end
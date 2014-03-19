class RatingDataReader < SchoolProfileDataReader

  def data
    #Get the ratings from the database.
    results = RatingsHelper.fetch_ratings_for_school school

    #Build a hash to hold the ratings results.
    gs_rating_value = RatingsHelper.construct_GS_ratings results, school
    city_rating_value =  RatingsHelper.construct_city_ratings results, school
    state_rating_value = RatingsHelper.construct_state_ratings results, school
    preK_ratings = RatingsHelper.construct_preK_ratings results, school

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
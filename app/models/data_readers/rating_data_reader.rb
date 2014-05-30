class RatingDataReader < SchoolProfileDataReader

  def data
    return @data if defined?(@data)

    #Get the ratings configuration from the database.
    ratings_config = RatingsConfiguration.configuration_for_school(school.state)

    #Get the ratings from the database.
    cached_ratings = SchoolCache.for_school('ratings',school.id, school.state)
    begin
      results = cached_ratings.nil? ? [] : JSON.parse(cached_ratings.value)
    rescue JSON::ParserError => e
      results = []
      Rails.logger.debug "ERROR: parsing JSON ratings from school cache for school: #{school.id} in state: #{school.state}" +
                           "Exception message: #{e.message}"
    end

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

    @data = return_var
  end

end
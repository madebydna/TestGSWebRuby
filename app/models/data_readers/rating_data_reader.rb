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
    @data = %w[gs_rating city_rating state_rating preschool_rating pcsb_rating].each_with_object({}) do |name, hash|
      method_name = "construct_#{name}"
      ratings = ratings_helper.send method_name, school
      if ratings.present?
        hash[name] = ratings
      end
    end
  end

end
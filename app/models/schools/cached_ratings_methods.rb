module CachedRatingsMethods

  NO_RATING_TEXT = 'NR'
  GREATSCHOOLS_RATINGS_NAMES = ['GreatSchools rating','Test score rating', 'Student growth rating', 'College readiness rating', 'Climate rating']
  HISTORICAL_RATINGS_KEYS = %w(year school_value_float)

  # 151: Advanced Course Rating
  # 155: Test Score Rating
  # 156: College Readiness Rating
  # 157: Student Progress Rating
  # 158: Equity Rating
  # 159: Academic Progress Rating
  # 160: Summary Rating

  def ratings
    cache_data['ratings'] || []
  end

  def ratings_by_type
    @_ratings_by_type ||= (
      (cache_data['ratings'] || {}).each_with_object({}) do |(type, array), hash|
        hash[type] = GsdataCaching::GsDataValue.from_array_of_hashes(array)
      end
    )
  end

  # ignore nil criteria
  def ratings_matching_criteria(ratings, criteria)
    # if all criteria are contained within the rating (after removing nil
    # values) then we have a match
    ratings.select { |rating| (criteria.compact.to_a - rating.to_a).empty? }
  end

  def overall_gs_rating
    rating_for_key('Summary Rating')
  end

  def great_schools_rating
    test_score_weight = (rating_weights.fetch('Summary Rating Weight: Test Score Rating', []).first || {})['school_value']
    if overall_gs_rating.nil? && test_score_weight == '1'
      test_scores_rating
    else
      overall_gs_rating
    end
  end

  def great_schools_rating_year
    rating_year_for_key('Summary Rating')
  end

  def test_scores_rating
    rating_for_key('Test Score Rating')
  end

  def test_scores_rating_hash
    test_scores_rating_hash_map_to_old_format(rating_object_for_key('Test Score Rating'), 'Test Score Rating')
  end

  def test_scores_all_rating_hash
    test_scores_rating_hash_loop_through_and_update(ratings_by_type['Test Score Rating'], 'Test Score Rating')
  end

  def equity_overview_rating
    rating_for_key('Equity Rating')
  end

  def equity_overview_rating_hash
    rating_object_for_key('Equity Rating')
  end

  def equity_overview_rating_year
    rating_year_for_key('Equity Rating')
  end

  def courses_rating
    rating_for_key('Advanced Course Rating')
  end

  def courses_rating_array
    course_subject_group = (ratings_by_type['Advanced Course Rating'] || []).select {|o| o.breakdown_tags == 'course_subject_group'}
    course_subject_group.each_with_object({}) do |dv, accum|
      if dv.breakdowns.present?
        subject = dv.breakdowns.downcase.gsub(' ', '_')
        accum[subject] = dv.school_value_as_int
      end
    end
  end

  def courses_rating_year
    rating_year_for_key('Advanced Course Rating')
  end

  def academic_progress_rating_hash
    rating_object_for_key('Academic Progress Rating')
  end

  def academic_progress_rating_year
    rating_year_for_key('Academic Progress Rating')
  end

  def student_growth_rating
    rating_for_key('Student Progress Rating')
  end

  def student_growth_rating_year
    rating_year_for_key('Student Progress Rating')
  end

  def student_growth_rating_hash
    rating_object_for_key('Student Progress Rating')
  end

  def college_readiness_rating_hash
    rating_object_for_key('College Readiness Rating')
  end

  def college_readiness_rating
    rating_for_key('College Readiness Rating')
  end

  def college_readiness_rating_year
    rating_year_for_key('College Readiness Rating')
  end

  ####################################################################
  #
  # START - use with GSData
  #
  ####################################################################

  def rating_year_for_key(key)
    return nil unless ratings_by_type[key].present?

    ratings_by_type[key]
      .having_no_breakdown
      .most_recent_source_year
  end

  def rating_for_key(key, breakdown = nil)
    rating_object_for_key(key, breakdown).try(:school_value_as_int)
  end

  # nil breakdown returns overall rating for key
  # returns ratings for most recent year
  def rating_object_for_key(key, breakdown = nil)
    return nil unless ratings_by_type[key].present?
    result = ratings_by_type[key].having_most_recent_date
    result = breakdown.nil? ? result.having_no_breakdown : result.having_breakdown_in(breakdown)
    result.having_school_value.expect_only_one(
      'rating object for key',
      rating_type: key,
      breakdown: breakdown
    )
  end

  # return array of ratings hashes for key
  def rating_hashes_for_key(key)
    if ratings.present?
      ratings[key] || []
    else
      []
    end
  end

  def test_scores_rating_hash_loop_through_and_update(array, data_type)
    return [] if array.nil? || data_type.nil?
    array.map { | hash |  test_scores_rating_hash_map_to_old_format(hash, data_type) }
  end

  def test_scores_rating_hash_map_to_old_format(hash, data_type)
    return nil if hash.nil?
    h = {}
    h['school_value_float'] = hash.school_value.to_i
    h['year'] = hash.source_year.to_i
    h['test_data_type_display_name'] = data_type
    h['breakdown'] = hash.breakdowns
    h['methodology'] = hash.methodology
    h['description'] = hash.description
    h
  end

  ####################################################################
  #
  # END - use with GSData
  #
  ####################################################################

  def formatted_non_greatschools_ratings
    formatted_ratings('other')
  end

  def formatted_greatschools_ratings
    formatted_ratings('gs_rating')
  end

  protected

  def all_great_schools_ratings
    ratings.select { |rating| GREATSCHOOLS_RATINGS_NAMES.include?(rating['name']) }
  end

  def non_great_schools_ratings
    ratings.select { |rating| !GREATSCHOOLS_RATINGS_NAMES.include?(rating['name']) }
  end

  # {"gs_rating"=>{174=>"GreatSchools rating", 164=>"Test score rating",
  # 165=>"Student progress rating", 166=>"College readiness rating",
  # 173=>"Climate rating"}}
  def formatted_ratings(rating_type=nil)
    if rating_type.nil? || rating_type == 'gs_rating'
      {
       :'GreatSchools rating' => :great_schools_rating,
       :'Test score rating' => :test_scores_rating,
       :'Student progress rating' => :student_growth_rating,
       :'College readiness rating' => :college_readiness_rating,
       :'Equity rating' => :equity_overview_rating
      }.each_with_object({}) do |(name, method), accum|
        result = send(method)
        accum[name.to_s] = result if result
      end
    else
      {}
    end
  end

  def rating_weights
    cache_data.fetch('gsdata', {}).select do |key, val|
      key.include?('Summary Rating Weight')
    end
  end
end

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

  # this will return true if cached ratings data is old format and not gsdata
  def ratings_cache_old?
    ratings.instance_of?(Array)
  end

  # ignore nil criteria
  def ratings_matching_criteria(ratings, criteria)
    # if all criteria are contained within the rating (after removing nil
    # values) then we have a match
    ratings.select { |rating| (criteria.compact.to_a - rating.to_a).empty? }
  end

  def ratings_having_max_year(ratings)
    return ratings unless ratings.present?
    year = ratings.max_by { |rating| rating['year'] }['year']
    ratings.select { |rating| rating['year'] == year }
  end

  def overall_gs_rating
    if ratings_cache_old?
      great_schools_rating.to_s.downcase
    else
      rating_for_key('Summary Rating')
    end
  end

  def great_schools_rating
    if ratings_cache_old?
      school_rating_by_id(174)
    else
      summary_rating = rating_for_key('Summary Rating')
      test_score_weight = (rating_weights.fetch('Summary Rating Weight: Test Score Rating', []).first || {})['school_value']
      if summary_rating.nil? && test_score_weight == '1'
        test_scores_rating
      else
        summary_rating
      end
    end
  end

  def test_score_rating_only?
    rating_for_key('Summary Rating').nil? && (rating_weights.fetch('Summary Rating Weight: Test Score Rating', []).first || {})['school_value'] == '1'
  end

  def great_schools_rating_year
    if ratings_cache_old?
      school_rating_year_by_id(174)
    else
      rating_year_for_key('Summary Rating')
    end
  end

  def test_scores_rating
    if ratings_cache_old?
      school_rating_by_id(164)
    else
      rating_for_key('Test Score Rating')
    end
  end

  def test_scores_rating_hash
    if ratings_cache_old?
      school_rating_hash_by_id(164)
    else
      test_scores_rating_hash_map_to_old_format(rating_hash_for_key_and_breakdown('Test Score Rating'), 'Test Score Rating')
    end
  end

  def test_scores_all_rating_hash
    if ratings_cache_old?
      school_rating_all_hash_by_id(164)
    else
      test_scores_rating_hash_loop_through_and_update(rating_hashes_for_key('Test Score Rating'), 'Test Score Rating')
    end
  end

  def equity_overview_rating
    rating_for_key('Equity Rating')
  end

  def equity_overview_rating_hash
    rating_hash_for_key_and_breakdown('Equity Rating')
  end

  def equity_overview_rating_year
    rating_year_for_key('Equity Rating')
  end

  def courses_rating
    rating_for_key('Advanced Course Rating')
  end

  def courses_rating_array
    course_subject_group = rating_hashes_for_key('Advanced Course Rating').select {|h| h['breakdown_tags'] == 'course_subject_group'}
    course_subject_group.each_with_object({}) do |dv, accum|
      if dv['breakdowns'].present?
        subject = dv['breakdowns'].downcase.gsub(' ', '_')
        accum[subject] = dv['school_value'].to_i if dv['school_value'].present?
      end
    end
  end

  def courses_rating_year
    rating_year_for_key('Advanced Course Rating')
  end

  def academic_progress_rating
    rating_for_key('Equity Rating')
  end

  def academic_progress_rating_hash
    rating_hash_for_key_and_breakdown('Academic Progress Rating')
  end

  def academic_progress_rating_year
    rating_year_for_key('Academic Progress Rating')
  end

  def student_growth_rating
    if ratings_cache_old?
      school_rating_by_id(165)
    else
      rating_for_key('Student Progress Rating')
    end
  end

  def student_growth_rating_year
    if ratings_cache_old?
      school_rating_year_by_id(165)
    else
      rating_year_for_key('Student Progress Rating')
    end
  end

  def student_growth_rating_hash
    if ratings_cache_old?
      school_rating_hash_by_id(165)
    else
      rating_hash_for_key_and_breakdown('Student Progress Rating')
    end
  end

  def college_readiness_rating_hash
    if ratings_cache_old?
      school_rating_hash_by_id(166)
    else
      rating_hash_for_key_and_breakdown('College Readiness Rating')
    end
  end

  def college_readiness_rating
    if ratings_cache_old?
      school_rating_by_id(166)
    else
      rating_for_key('College Readiness Rating')
    end
  end

  def college_readiness_rating_year
    if ratings_cache_old?
      school_rating_year_by_id(166)
    else
      rating_year_for_key('College Readiness Rating')
    end
  end

  def historical_test_scores_ratings
    if ratings_cache_old?
      school_historical_rating_hashes_by_id(164)
    else
      []
    end
  end

  def historical_college_readiness_ratings
    if ratings_cache_old?
      school_historical_rating_hashes_by_id(166)
    else
      []
    end
  end

  def historical_student_growth_ratings
    if ratings_cache_old?
      school_historical_rating_hashes_by_id(165)
    else
      []
    end
  end

  ####################################################################
  #
  # START - use with GSData
  #
  ####################################################################

  def rating_year_for_key(key)
    hash = rating_hash_for_key_and_breakdown(key)
    if hash.present?
      year_for_date(hash['source_date_valid'])
    end
  end

  def year_for_date(str_date)
    DateTime.parse(str_date).strftime('%Y').to_i if str_date.present?
  end

  def rating_for_key_and_breakdown(key, breakdown)
    hash = rating_hash_for_key_and_breakdown(key, breakdown)
    hash['school_value'].to_i if hash.present? && hash['school_value'].present?
  end

  def rating_for_key(key)
    hash = rating_hash_for_key_and_breakdown(key)
    hash['school_value'].to_i if hash.present? && hash['school_value'].present?
  end

  def select_by_max_date(array_of_hashes)
    max_date = array_of_hashes.map{|h| h['source_date_valid']}.max
    array_of_hashes.select { |dv| dv['source_date_valid'] == max_date }.first
  end

  # nil breakdown returns overall rating for key
  # returns ratings hash for most recent year
  def rating_hash_for_key_and_breakdown(key, breakdown = nil)
    return nil unless ratings.present? && ratings.is_a?(Hash)
    arr_of_h = ratings[key].select{ |h| h['breakdowns'] == breakdown } if ratings[key].present?
    if arr_of_h.present?
      select_by_max_date(arr_of_h)
    end
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
    hash['school_value_float'] = hash['school_value'].to_i
    hash['year'] = year_for_date(hash['source_date_valid']).to_i
    hash['test_data_type_display_name'] = data_type
    hash['breakdown'] = hash['breakdowns']
    hash
  end

  ####################################################################
  #
  # END - use with GSData
  #
  ####################################################################

  def school_rating_hash_by_id(rating_id, level_code=nil)
    raise 'Must provide rating data type ID as first argument' unless rating_id

    relevant_ratings = ratings_matching_criteria(
      ratings,
      'data_type_id' => rating_id,
      'level_code' => level_code,
      'breakdown' => 'All students'
    )
    relevant_ratings = ratings_having_max_year(relevant_ratings)
    relevant_ratings.first # there should only be one
  end

  def school_rating_all_hash_by_id(rating_id, level_code=nil)
    raise 'Must provide rating data type ID as first argument' unless rating_id

    relevant_ratings = ratings_matching_criteria(
      ratings,
      'data_type_id' => rating_id,
      'level_code' => level_code
    )
    ratings_having_max_year(relevant_ratings)
  end

  def school_historical_rating_hashes_by_id(rating_id)
    raise 'Must provide rating data type ID as first argument' unless rating_id

    historical_ratings = ratings_matching_criteria(
      ratings,
      'data_type_id' => rating_id,
      'breakdown' => 'All students'
    )
    historical_ratings_filtered = historical_ratings.map do |hash|
      hash['school_value_float'] = hash['school_value_float'].try(:to_i)
      hash.select { |k, _| HISTORICAL_RATINGS_KEYS.include?(k) }
    end

    return historical_ratings_filtered.sort_by{ |hash| hash['year'] }.reverse
  end

  def school_rating_by_id(rating_id=nil, level_code=nil)
    if rating_id
      # allow caller to provide level_code as 2nd arg. If given,
      # find only ratings that match it (and date type ID)
      ratings_obj = school_rating_hash_by_id(rating_id, level_code)
      if ratings_obj
        if ratings_obj['school_value_text']
          return ratings_obj['school_value_text']
        elsif ratings_obj['school_value_float']
          return ratings_obj['school_value_float'].to_i
        end
      end
    end
    NO_RATING_TEXT
  end

  def school_rating_year_by_id(rating_id=nil, level_code=nil)
    if rating_id
      # allow caller to provide level_code as 2nd arg. If given,
      # find only ratings that match it (and date type ID)
      ratings_year_obj = school_rating_hash_by_id(rating_id, level_code)
      return ratings_year_obj['year'].to_i if ratings_year_obj
    end
    nil
  end

  def displayed_ratings
    ratings_labels = Hash.new { |h,k| h[k] = {} }
    ratings_labels['gs_rating'][174] = 'GreatSchools rating'
    ratings_config = RatingsConfiguration.configuration_for_school(state)
    ratings_config.each do |rating_type, rating_type_hash|
      if rating_type_hash.is_a?(Hash)
        if rating_type == 'gs_rating'
          # Only show sub-ratings for GS ratings
          rating_level = 'rating_breakdowns'
        else
          rating_type = 'other'
          rating_level = 'overall'
        end
        rating_description = rating_type_hash[rating_level]
        if rating_description.is_a?(Array)
          # If rating_description is Array, make a new config that has
          # so that pairs of data types / level codes are used for each
          # rating config key rather than just data type ID
          rating_description = fix_config_for_co(rating_description)
          # Get a hash of data type ID => label
          # The other branches of this if..else block do the same thing, I
          # just made a method for it
          data_types_and_labels = 
            extract_data_types_and_labels_from_rating_descriptions(rating_description)
          ratings_labels[rating_type] = data_types_and_labels
        elsif rating_description.values.first.is_a?(Hash)
          rating_description.values.each do |description|
            if description['data_type_id']
              ratings_labels[rating_type][description['data_type_id']] = description['label']
            end
          end
        elsif rating_description['data_type_id']
          ratings_labels[rating_type][rating_description['data_type_id']] = rating_description['label']
        end
      end
    end
    ratings_labels
  end

  def extract_data_types_and_labels_from_rating_descriptions(array_of_rating_descriptions)
    array_of_rating_descriptions.each_with_object({}) do |rating_description, hash|
      if rating_description['data_type_id']
        hash[rating_description['data_type_id']] = rating_description['label']
      end
    end
  end

  def fix_config_for_co(config)
    config = config.clone
    config.each do |hash|
      hash['data_type_id'] = [hash['data_type_id'],hash['level_code']]
    end
    config
  end

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
       :'Test scores rating' => :test_scores_rating,
       :'Student progress rating' => :student_growth_rating,
       :'Academic progress rating' => :academic_progress_rating,
       :'College readiness rating' => :college_readiness_rating,
       :'Advanced courses rating' => :courses_rating,
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

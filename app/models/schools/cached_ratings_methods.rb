module CachedRatingsMethods

  NO_RATING_TEXT = 'NR'

  def ratings
    cache_data['ratings'] || {}
  end

  def overall_gs_rating
    great_schools_rating
  end

  def great_schools_rating
    school_rating_by_data_type_id(174)
  end

  def test_scores_rating
    school_rating_by_data_type_id(164)
  end

  def student_growth_rating
    school_rating_by_data_type_id(165)
  end

  def school_rating_by_data_type_id(data_type_id)
    overall_ratings_obj = ratings.find { |rating| rating['data_type_id'] == data_type_id  }
    if overall_ratings_obj
      overall_ratings_obj['school_value_float'].to_i
    else
      NO_RATING_TEXT
    end
  end

end
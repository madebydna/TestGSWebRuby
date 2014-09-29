module CachedRatingsMethods

  NO_RATING_TEXT = 'NR'

  def ratings
    cache_data['ratings'] || []
  end

  def overall_gs_rating
    great_schools_rating.to_s.downcase
  end

  def great_schools_rating
    school_rating_by_name('GreatSchools rating')
  end

  def test_scores_rating
    school_rating_by_name('Test scores rating')
  end

  def student_growth_rating
    school_rating_by_name('Student growth rating')
  end

  def college_readiness_rating
    school_rating_by_name('College readiness rating')
  end

  def school_rating_by_name(rating_name=nil)
    ratings_obj = ratings.find { |rating| rating['name'] == rating_name  }
    if rating_name && ratings_obj
      if ratings_obj['school_value_text']
        ratings_obj['school_value_text']
      elsif ratings_obj['school_value_float']
        ratings_obj['school_value_float'].to_i
      else
        NO_RATING_TEXT
      end
    else
      NO_RATING_TEXT
    end
  end

end
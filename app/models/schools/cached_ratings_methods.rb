module CachedRatingsMethods

  NO_RATING_TEXT = 'NR'
  GREATSCHOOLS_RATINGS_NAMES = ['GreatSchools rating','Test score rating', 'Student growth rating', 'College readiness rating', 'Climate rating']

  def ratings
    cache_data['ratings'] || []
  end

  def overall_gs_rating
    great_schools_rating.to_s.downcase
  end

  def great_schools_rating
    school_rating_by_id(174)
  end

  def test_scores_rating
    school_rating_by_id(164)
  end

  def student_growth_rating
    school_rating_by_id(165)
  end

  def college_readiness_rating
    school_rating_by_id(166)
  end

  def school_rating_by_id(rating_id=nil)
    ratings_obj = ratings.find { |rating| rating['data_type_id'] == rating_id }
    if rating_id && ratings_obj
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

  def all_great_schools_ratings
    ratings.select { |rating| GREATSCHOOLS_RATINGS_NAMES.include?(rating['name']) }
  end

  def non_great_schools_ratings
    ratings.select { |rating| !GREATSCHOOLS_RATINGS_NAMES.include?(rating['name']) }
  end
end
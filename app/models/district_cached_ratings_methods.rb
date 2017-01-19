module DistrictCachedRatingsMethods

  NO_RATING_TEXT = 'NR'

  def ratings
    cache_data['ratings'] || []
  end

  def overall_gs_rating
    great_schools_rating.to_s.downcase
  end

  def great_schools_rating
    rating_by_id(174)
  end


  def rating_by_id(rating_id=nil, level_code=nil)
    if rating_id
      # allow caller to provide level_code as 2nd arg. If given,
      # find only ratings that match it (and date type ID)
      ratings_obj = ratings.find do |rating|
        rating['data_type_id'] == rating_id && (
          level_code.nil? || level_code == rating['level_code']
        )
      end
      if ratings_obj
        if ratings_obj['value_text']
          return ratings_obj['value_text']
        elsif ratings_obj['value_float']
          return ratings_obj['value_float'].to_i
        end
      end
    end
    NO_RATING_TEXT
  end



end

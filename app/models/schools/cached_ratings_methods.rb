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
    if rating_id
      ratings_obj = ratings.find { |rating| rating['data_type_id'] == rating_id }
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
        if rating_description.values.first.is_a?(Hash)
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

  def formatted_ratings(rating_type=nil)
    formatted_ratings = {}
    ratings_labels = displayed_ratings
    ratings_labels = ratings_labels[rating_type] if rating_type
    ratings_labels.each do |rating_id , rating_label|
      school_rating = school_rating_by_id(rating_id)
      formatted_ratings[rating_label] = school_rating
    end
    formatted_ratings
  end
end
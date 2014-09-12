class SchoolCompareDecorator < SchoolProfileDecorator

  decorates :school
  delegate_all

  NO_DATA_SYMBOL = '?'
  NO_RATING_TEXT = 'NR'

  def cache_data
    # Draper special initialize key
    context
  end

  ################################ Characteristics ################################

  def characteristics
    cache_data['characteristics'] || {}
  end

  def students_enrolled
    if valid_characteristic_cache(characteristics['Enrollment'])
      number_with_delimiter(characteristics['Enrollment'].first['school_value'].to_i, delimiter: ',')
    else
      NO_DATA_SYMBOL
    end
  end

  def ethnicity_data
    characteristics['Ethnicity'] || []
  end

  def graduates_high_school
    style_school_value_as_percent('Graduation rate')
  end

  def enroll_in_college
    style_school_value_as_percent('Percent enrolled in any institution of higher learning in the last 0-16 months')
  end

  def stays_2nd_year
    style_school_value_as_percent('Percent Enrolled in College and Returned for a Second Year')
  end

  def style_school_value_as_percent(data_name)
    if valid_characteristic_cache(characteristics[data_name])
      value = characteristics[data_name].first['school_value'].to_i
      if value
        "#{value.round(0)}%"
      end
    else
      NO_DATA_SYMBOL
    end
  end

  def valid_characteristic_cache(cache)
    if cache && cache.is_a?(Array)
      true
    else
      false
    end
  end

  ################################ Reviews ################################

  def reviews_snapshot
    cache_data['reviews_snapshot'] || {}
  end

  def star_rating
    reviews_snapshot['avg_star_rating'] || 0
  end

  def num_reviews
    reviews_snapshot['num_reviews'] || 0
  end

  def num_ratings
    reviews_snapshot['num_ratings'] || 0
  end

  ################################# Programs ##################################

  def programs
    cache_data['esp_responses'] || {}
  end

  def transportation
    case programs['transportation']
      when 'none'
        'No'
      when nil
        NO_DATA_SYMBOL
      else
        'Yes'
    end
  end

  def before_care
    before_after_care('before')
  end

  def after_school
    before_after_care('after')
  end

  def before_after_care(before_after)
    if programs['before_after_care']
      if programs['before_after_care'].keys.include?(before_after)
        'Yes'
      elsif programs['before_after_care'].keys.include?('neither')
        'No'
      else
        NO_DATA_SYMBOL
      end
    else
      NO_DATA_SYMBOL
    end
  end

  def sports
    num_programs('boys_sports','girls_sports','boys_sports_other','girls_sports_other')
  end

  def clubs
    num_programs('student_clubs','student_clubs_other')
  end

  def world_languages
    num_programs('foreign_language')
  end

  def arts_and_music
    num_programs('arts_music','arts_media','arts_performing_written','arts_visual')
  end

  def num_programs(*program_keys)
    count = 0
    show_numeric = false
    program_keys.each do |program|
      if programs.key? program
        keys = programs[program].keys - ['none']
        count += keys.size
        show_numeric = true
      end
    end
    if show_numeric
      count
    else
      NO_DATA_SYMBOL
    end
  end

  ################################# Quality ##################################

  def ratings
    cache_data['ratings'] || {}
  end

  def great_schools_rating
    school_rating_by_data_type_id(174)
  end

  def great_schools_rating_icon
    rating = school_rating_by_data_type_id(174)
    rating = 'nr' if rating == NO_RATING_TEXT
    "<i class=\"iconx24-icons i-24-new-ratings-#{rating}\"></i>".html_safe
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
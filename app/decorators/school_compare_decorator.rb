class SchoolCompareDecorator < SchoolProfileDecorator

  include ActionView::Helpers

  decorates :school
  delegate_all

  attr_accessor :prepped_ratings
  attr_accessor :prepped_ethnicities

  include FitScoreConcerns

  NO_DATA_SYMBOL = '?'
  NO_RATING_TEXT = 'NR'
  NO_ETHNICITY_SYMBOL = 'n/a'

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
      characteristics['Enrollment'].each do |enrollment|
        if enrollment['grade'].nil?
          return number_with_delimiter(enrollment['school_value'].to_i, delimiter: ',')
        end
      end
      NO_DATA_SYMBOL
    else
      NO_DATA_SYMBOL
    end
  end

  def ethnicity_data
    characteristics['Ethnicity'] || []
  end

  def school_ethnicity(breakdown)
    ethnicity_obj = prepped_ethnicities.find { |ethnicity| ethnicity['breakdown'] == breakdown  }
    if ethnicity_obj && ethnicity_obj['school_value']
      ethnicity_obj['school_value'].round.to_s + '%'
    else
      NO_ETHNICITY_SYMBOL
    end
  end

  def ethnicity_label_icon
    'fl square js-comparePieChartSquare'
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

  def school_page_path
    h.school_path(school)
  end

  def zillow_formatted_url
    h.zillow_url(school)
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
    if programs['transportation']
      if programs['transportation'].keys == ['none']
        'No'
      else
        'Yes'
      end
    else
      NO_DATA_SYMBOL
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
    cache_data['ratings'] || []
  end

  def great_schools_rating
    school_rating_by_name('GreatSchools rating')
  end

  def great_schools_rating_icon(rating_name=nil)
    rating = school_rating_by_name(rating_name).to_s.downcase
    "<i class='iconx24-icons i-24-new-ratings-#{rating}'></i>".html_safe
  end

  def school_rating_by_name(rating_name=nil)
    ratings_obj = ratings.find { |rating| rating['name'] == rating_name  }
    if rating_name && ratings_obj
      ratings_obj['school_value_float'].to_i
    else
      NO_RATING_TEXT
    end
  end

end
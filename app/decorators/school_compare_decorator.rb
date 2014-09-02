class SchoolCompareDecorator < SchoolProfileDecorator

  decorates :school
  delegate_all

  NO_DATA_SYMBOL = 'n/a'

  ################################ Characteristics ################################

  def characteristics
    return @characteristics if @characteristics
    @characteristics = begin JSON.parse(SchoolCache.for_school('characteristics',id,state).value) rescue {} end
  end

  def students_enrolled
    if characteristics['Enrollment']
      number_with_delimiter(characteristics['Enrollment'].first['school_value'].to_i, delimiter: ',')
    else
      NO_DATA_SYMBOL
    end
  end

  def ethnicity_data
    characteristics['Ethnicity']
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
    if characteristics[data_name]
      value = characteristics[data_name].first['school_value'].to_i
      if value
        "#{value.round(0)}%"
      end
    else
      NO_DATA_SYMBOL
    end
  end

  ################################ Reviews ################################

  def reviews_snapshot
    return @reviews_snapshot if @reviews_snapshot
    @reviews_snapshot = begin JSON.parse(SchoolCache.for_school('reviews_snapshot',id,state).value) rescue {} end
  end

  def star_rating
    reviews_snapshot['avg_star_rating'] || 0
  end

  def num_reviews
    reviews_snapshot['num_reviews'] || 0
  end

  ################################# Programs ##################################

  def programs
    return @programs if @programs
    @programs = begin JSON.parse(SchoolCache.for_school('esp_responses',id,state).value) rescue {} end
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
    if programs['before_after_care'] && programs['before_after_care'].keys.include?(before_after)
      'Yes'
    else
      NO_DATA_SYMBOL
    end
  end

  def num_sports
    num_programs('boys_sports','girls_sports','boys_sports_other','girls_sports_other')
  end

  def num_clubs
    num_programs('student_clubs','student_clubs_other')
  end

  def num_languages
    num_programs('foreign_language')
  end

  def num_arts_music
    num_programs('arts_music','arts_media','arts_performing_written','arts_visual')
  end

  def num_programs(*program_keys)
    count = 0
    program_keys.each do |program|
      count += programs[program].keys.size if programs.key? program
    end
    count
  end

  ################################# Quality ##################################

  def ratings
    return @ratings if @ratings
    @ratings = begin JSON.parse(SchoolCache.for_school('ratings',id,state).value) rescue {} end
  end

end
module CachedProgramsMethods

  NO_DATA_SYMBOL = '?'

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
end
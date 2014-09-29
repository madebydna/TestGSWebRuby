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

  def start_time
    if programs['start_time']
        programs['start_time'].keys.first
    end
  end

  def end_time
    if programs['end_time']
      programs['end_time'].keys.first
    end
  end

  def best_known_for
    if programs['best_known_for']
      programs['best_known_for'].keys.first
    end
  end

  def deadline
    if programs['application_deadline_date']
      programs['application_deadline_date'].keys.first
    elsif programs['application_deadline'] && !programs['application_deadline_date'] && programs['application_deadline'].keys.first=='yearround'
       'Rolling deadline'
    elsif programs['application_deadline'] && !programs['application_deadline_date'] && programs['application_deadline'].keys.first=='parents_contact'
      'Contact school'
    end
  end
end
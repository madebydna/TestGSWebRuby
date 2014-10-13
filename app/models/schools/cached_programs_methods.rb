module CachedProgramsMethods

  NO_DATA_SYMBOL = '?'
  NOT_APPLICABLE_SYMBOL ='n/a'

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
        keys = programs[program].keys - ['none'] - ['None']
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
    elsif  !programs['application_deadline']
      NOT_APPLICABLE_SYMBOL
    end
  end

  def tuition
    if programs['tuition_high'] && programs['tuition_low']
      programs['tuition_low'].keys.first+'-'+programs['tuition_high'].keys.first
    else
      NOT_APPLICABLE_SYMBOL
    end
  end

  def aid
    financial_id='No'
    if !programs['financial_aid']
      financial_id= NOT_APPLICABLE_SYMBOL
    elsif  programs['financial_aid'] &&  programs['financial_aid_type']
      programs['financial_aid_type'].each do |key,value|
        if key != 'tax_credits'
          financial_id='Yes'
        end
      end

    end
    financial_id
  end

  def tax_scholarship
    tax_credit='No'
    if !programs['financial_aid']
      tax_credit= NOT_APPLICABLE_SYMBOL
    elsif  programs['financial_aid'] &&  programs['financial_aid_type']
      programs['financial_aid_type'].each do |key , value|
        if key == 'tax_credits'
          tax_credit='Yes'
        end
      end

    end
    tax_credit

  end

  def voucher
    if programs['students_vouchers']
      programs['students_vouchers'].keys.first.capitalize
    else
      NOT_APPLICABLE_SYMBOL
    end
  end

  def early_childhood_programs
    if programs['early_childhood_programs']
      programs['early_childhood_programs'].keys.first.capitalize
    else
      NOT_APPLICABLE_SYMBOL
    end
  end

  def dress_code
    if programs['dress_code'] &&  (programs['dress_code'].keys.first == 'dress_code' || programs['dress_code'].keys.first == 'uniform')
          'Yes'
    elsif  programs['dress_code'] &&  programs['dress_code'].keys.first == 'no_dress_code'
          'No'
    else

      NOT_APPLICABLE_SYMBOL

    end
  end

  def ell
    if programs['ell_level']
      programs['ell_level'].keys.first.capitalize
    else
      NOT_APPLICABLE_SYMBOL
    end
  end

  def sped
    if programs['spec_ed_level']
      programs['spec_ed_level'].keys.first.capitalize
    else
      NOT_APPLICABLE_SYMBOL
    end
  end

  def destination_school_1
    if programs['destination_school_1']
      programs['destination_school_1'].keys.first
    end
  end

  def destination_school_2
    if programs['destination_school_2']
      programs['destination_school_2'].keys.first
    end
  end

  def destination_school_3
    if programs['destination_school_3']
      programs['destination_school_3'].keys.first
    end
  end
end
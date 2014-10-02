module CachedProgramsMethods

  NO_DATA_SYMBOL = '?'
  NOT_APPLICABLE_SYMBOL ='N/A'

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
    if programs['financial_aid'] &&  !programs['financial_aid_type']
       # Case when financial Aid is "no"
      programs['financial_aid'].keys.first
    elsif programs['financial_aid'] &&  programs['financial_aid_type']
             # Case when financial Aid is student based or outside and not Tax Credit .Tax Credit id called a seperate data point Tax Scholarship
             programs['financial_aid_type'].map do |key, value|
               if key == 'outside' || key =='school_based'
                  'I am here2'

                 programs['financial_aid'].keys.first
               end
             end
    elsif programs['financial_aid'] &&  programs['financial_aid_type']
      puts 'I am here3'

      # Case when financial Aid is student based or outside and not Tax Credit .Tax Credit id called a seperate data point Tax Scholarship
      programs['financial_aid_type'].map do |key, value|
        if key == 'tax_credits'
          puts 'I am here4'

          NOT_APPLICABLE_SYMBOL
        end
      end

    elsif
      NOT_APPLICABLE_SYMBOL
    end
  end

  def voucher
    if programs['students_vouchers']
      programs['students_vouchers'].keys.first
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
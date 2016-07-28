module AccountHelper

  def state_locale
    # User might not have a user_profile row in the db. It might be nil
    sl = @current_user.user_profile.try(:state)
    if sl.present?
      {
          long: States.state_name(sl.downcase.gsub(/\-/, ' ')),
          short: States.abbreviation(sl.downcase.gsub(/\-/, ' '))
      }
    end
  end

  def account_meta_tags(page_title)
    title = page_title << " | GreatSchools"
    set_meta_tags :title => title,
                  :robots => "noindex"
  end

  def grade_array_pk_to_12
    ['PK', 'KG', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12']
  end

  def grade_array_pk_to_8
    ['PK', 'KG', '1', '2', '3', '4', '5', '6', '7', '8']
  end

  def available_grades
    {
        'PK' => 'PK',
        'KG' => 'K',
        '1' => '1st',
        '2' => '2nd',
        '3' => '3rd',
        '4' => '4th',
        '5' => '5th',
        '6' => '6th',
        '7' => '7th',
        '8' => '8th',
        '9' => '9th',
        '10' => '10th',
        '11' => '11th',
        '12' => '12th'
    }
  end

end

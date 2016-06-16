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


  def verify_and_login_user(token)
    begin
      parsed_token = UserVerificationToken.parse(token)
    rescue UserVerificationToken::UserVerificationTokenParseError => error
      GSLogger.warn(:misc, error)
      parsed_token = nil
    end

    if parsed_token && parsed_token.valid?
      log_user_in UserVerificationToken.parse(token).user
    else
      redirect_to signin_url
    end
  end
end

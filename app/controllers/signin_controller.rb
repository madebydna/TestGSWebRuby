class SigninController < ApplicationController
  include ReviewControllerConcerns

  protect_from_forgery

  layout 'application'

  # gets the reg / sigin form page
  def new
  end

  def authenticate
    existing_user = User.where(email: params[:email]).first
    error = nil

    if existing_user
      if existing_user.password_matches params[:password]
        # no op
      elsif existing_user.provisional?
        error = 'You must validate your email in order to log in'
      else
        error = 'Sorry, your email or password was incorrect.'
      end
    else
      # no matching user
      error = 'Sorry, your email or password was incorrect.'
    end

    return existing_user, error
  end

  def register
    json = social_registration_and_login

    if json[:success]
      return nil, nil
    else
      return nil, json[:error_message]
    end
  end

  # rather than invoke different controller actions for login / join, determine intent by presence of certain params
  def should_attempt_login
    is_registration = params[:password].nil? && params[:confirm_password].nil?
    return !is_registration
  end

  # handles registration and login
  def create

    if should_attempt_login
      user, error = authenticate  # log in
    else
      user, error = register      # join
    end

    # successful login or registration is determined by presence of error
    if error
      flash_error error
      redirect_to signin_path
    else
      if should_attempt_login
        log_user_in(user)
        flash_notice 'Welcome to GreatSchools!'
        process_pending_actions
      else
        flash_notice 'Please verify your email address so we can finish setting up your account. [verification not implemented, go ahead and log in. password = "password"]'
        if get_review_params
          flash_notice 'Thanks for your school review! We\'ll post it once your email address has been verified.'
        end
        redirect_back_or_default('/california/alameda/1-alameda-high-school') # should not go to index page
      end
    end
  end

  # upon successful authentication, handle whatever user was trying to do previously
  # save pending form posts and/or redirect user
  def process_pending_actions
    review_params = get_review_params
    if review_params
      if save_review(review_params)
        clear_review_params
        flash_notice 'Thanks, your review has been posted. Your feedback helps other parents choose the right schools!'
        redirect_back_or_default('/california/alameda/1-alameda-high-school') # should not go to index page
      else
        redirect_back_or_default('/california/alameda/1-alameda-high-school') # should not go to index page
        # TODO: what to do here?
      end
    else
      redirect_back_or_default('/california/alameda/1-alameda-high-school') # TODO: where do we redirect if no cookie set?
    end
  end

  # handle logout
  def destroy
    log_user_out
    flash_notice 'Signed out'
    redirect_to(signin_url)
  end

  def facebook_authentication
    json = social_registration_and_login

    respond_to do |format|
      format.json  { render :json => json }
    end
  end

end

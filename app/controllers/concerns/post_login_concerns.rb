module PostLoginConcerns
  extend ActiveSupport::Concern

  def save_post_signin_action(action, params)
    session[:after_signin] = [action, params]
  end

  def get_post_login_action
    if session[:after_signin]
      return *session[:after_signin]
    end
  end

  def create_subscription(params)
    begin
      list = params[:list]
      school_id = params[:school_id]
      state = params[:state]
      message = params[:message]
      if school_id.present? && state.present?
        school = School.on_db(state.downcase.to_sym).find school_id
      else
        school = nil
      end

      raise 'Subscription could not be added since a list was not provided.' if list.nil?

      unless current_user.has_subscription? list
        current_user.add_subscription!(list, school)
      end
      flash_notice message if message
      redirect_back_or_default
    rescue => e
      flash_error e.message
      redirect_back_or_default
    end
  end



end

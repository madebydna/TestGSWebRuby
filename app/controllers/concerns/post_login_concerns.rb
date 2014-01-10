module PostLoginConcerns
  extend ActiveSupport::Concern

  def save_post_signin_action(action, params)
    cookies[:after_signin] = [action, params].to_json
  end

  def get_post_login_action
    if cookies[:after_signin]
      begin
        data = JSON.parse(cookies[:after_signin], {:symbolize_names => true})
        return *data
      rescue
        return nil
      end
    end
  end

  def execute_post_login_action
    action, params = get_post_login_action

    if action.present? && self.respond_to?(action)
      begin
        self.send action, params
        cookies.delete :after_signin
      rescue => error
        Rails.logger.debug "Error when executing post login action: #{action} on #{self.class}. #{error.message}"
      end
    else
      Rails.logger.debug "Action: #{action} not present on #{self.class}."
      cookies.delete :after_signin
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
    rescue => e
      flash_error e.message
    end
  end



end

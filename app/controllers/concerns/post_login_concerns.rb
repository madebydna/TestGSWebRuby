module PostLoginConcerns
  extend ActiveSupport::Concern

  def save_post_email_verification_action(action, params)
    write_cookie_value :after_email_verification, [action, params]
  end

  def get_post_email_verification_action
    read_cookie_value :after_email_verification
  end

  def execute_post_email_verification_action
    action, params = get_post_email_verification_action

    if action.present? && self.respond_to?(action)
      begin
        self.send action, params
        delete_cookie :after_email_verification
      rescue => error
        Rails.logger.debug "Error when executing post email verification action: #{action} on #{self.class}. #{error.message}"
      end
    else
      Rails.logger.debug "Action: #{action} not present on #{self.class}."
      delete_cookie :after_email_verification
    end
  end

  def save_post_authenticate_action(action, params)
    write_cookie_value :after_authenticate, [action, params]
  end

  def get_post_authenticate_action
    read_cookie_value :after_authenticate
  end

  def execute_post_authenticate_action
    action, params = get_post_authenticate_action

    if action.present? && self.respond_to?(action)
      begin
        self.send action, params
        delete_cookie :after_authenticate
      rescue => error
        Rails.logger.debug "Error when executing post authenticate action: #{action} on #{self.class}. #{error.message}"
      end
    else
      Rails.logger.debug "Action: #{action} not present on #{self.class}."
      delete_cookie :after_authenticate
    end
  end





end

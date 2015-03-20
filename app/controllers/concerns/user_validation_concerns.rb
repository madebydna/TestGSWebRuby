module UserValidationConcerns
  extend ActiveSupport::Concern

  def validate_user(&block)
    user = nil
    error_msg = email_param_error
    return [user, error_msg] if error_msg

    user = user_from_email_param

    if user.nil?
      error_key = 'nonexistent_join'
    elsif ! user.has_password? # Users without passwords (signed up via newsletter) are not considered users, so those aren't real accounts
      error_key = 'account_without_password'
    elsif user.provisional?
      error_key = 'provisional_resend_email'
    elsif user.has_inactive_profile?
      error_key = 'de_activated'
    end

    error_msg = get_error_message(user, error_key, &block)

    return user, error_msg
  end

  def email_param_error
    email_param = params[:email]

    return t('forms.errors.email.blank') if email_param.blank?
    return t('forms.errors.email.format') unless email_format_valid?

    return nil
  end

  def email_format_valid?
    EmailValidator.new(params[:email]).format_valid?
  end

  def user_from_email_param
    User.find_by_email(params[:email])
  end

  def get_error_message(user,error_key)
    if block_given?
      custom_error_messages = yield
      error_messages_hash = custom_error_messages.reverse_merge(default_error_messages(user))
    else
      error_messages_hash = default_error_messages(user)
    end

    error_messages_hash[error_key] or nil
  end

  def default_error_messages(user)
    verification_email_url = user.present? ? url_for(:controller => '/user', :action => 'send_verification_email', :email => user.email) : ''
    {
      'nonexistent_join' => t('forms.errors.email.nonexistent_join', join_path: join_path).html_safe,
      'account_without_password' => t('forms.errors.email.account_without_password', join_path: join_path).html_safe,
      'provisional_resend_email' => (t('forms.errors.email.provisional_resend_email', verification_email_url: verification_email_url)).html_safe,
      'de_activated' => t('forms.errors.email.de_activated').html_safe
    }
  end


end
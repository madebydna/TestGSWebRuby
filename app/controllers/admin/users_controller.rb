class Admin::UsersController < ApplicationController
  include UserValidationConcerns

  def generate_reset_password_link
    user, err_msg = validate_user(&error_message_hash)

    if err_msg.present?
      flash_error err_msg
    elsif user
      @reset_password_link = reset_password_url+
        '?id='+CGI.escape(user.auth_token)+
        '&s_cid=eml_passwordreset'
      render 'admin/users/search'
      return
    end
    redirect_to admin_users_search_url
  end

  protected

  def error_message_hash
    Proc.new do
      {
        'nonexistent_join' => t('forms.admin.errors.email.nonexistent').html_safe,
        'account_without_password' => t('forms.admin.errors.email.account_without_password').html_safe,
        'provisional_resend_email' => t('forms.admin.errors.email.provisional').html_safe,
        'de_activated' => t('forms.admin.errors.email.de_activated').html_safe
      }
    end
  end


end
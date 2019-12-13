class Admin::UsersController < ApplicationController
  include UserValidationConcerns

  layout 'deprecated_application_with_webpack'

  def user_help
    render 'admin/users/user_help'
  end

  def generate_reset_password_link
    user, err_msg = validate_user_can_reset_password(&error_message_hash)

    if err_msg.present?
      flash_error err_msg
    elsif user
      @reset_password_link = create_reset_password_url(user)
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
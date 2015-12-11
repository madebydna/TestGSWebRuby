require 'addressable/uri'
class ResetPasswordEmail < AbstractExactTargetMailer

  self.exact_target_email_key = 'forgot_password'
  self.priority = 'High' # Valid options = Low | Medium | High

  def self.deliver_to_user(user, reset_password_url)
    exact_target_email_attributes = {
      RESET_LINK: reset_password_url
    }
    deliver(user.email, exact_target_email_attributes)
  end

end

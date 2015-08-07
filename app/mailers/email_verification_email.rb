require 'addressable/uri'
class EmailVerificationEmail < AbstractExactTargetMailer

  self.exact_target_email_key = 'join_verification_email_password'
  self.priority = 'High' # Valid options = Low | Medium | High

  def self.deliver_to_user(user, email_verification_url)
    exact_target_email_attributes = {
      VERIFICATION_LINK: "<a href=\"#{email_verification_url}\">#{email_verification_url}</a>",
      PASSWORD: user.password,
    }

    deliver(user.email, exact_target_email_attributes)
  end

end

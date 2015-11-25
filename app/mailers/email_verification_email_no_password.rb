require 'addressable/uri'
class EmailVerificationEmailNoPassword < AbstractExactTargetMailer

  self.exact_target_email_key = 'join_verification_email_no_password'
  self.priority = 'High' # Valid options = Low | Medium | High

  def self.deliver_to_user(user, email_verification_url)
    exact_target_email_attributes = {
      VERIFICATION_LINK: email_verification_url
    }

    deliver(user.email, exact_target_email_attributes)
  end

end

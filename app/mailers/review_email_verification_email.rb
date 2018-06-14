# frozen_string_literal: true

class ReviewEmailVerificationEmail < AbstractExactTargetMailer

  self.exact_target_email_key = 'school_review_new_confirmation'
  self.priority = 'High' # Valid options = Low | Medium | High

  def self.deliver_to_user(user, email_verification_url, school_name)
    exact_target_email_attributes = {
        HTML__reviewLink: email_verification_url,
        schoolName: school_name
    }

    deliver(user.email, exact_target_email_attributes)
  end

end

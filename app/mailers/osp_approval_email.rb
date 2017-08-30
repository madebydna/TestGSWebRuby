require 'addressable/uri'
class OspApprovalEmail < AbstractExactTargetMailer

  self.exact_target_email_key = 'ESP-approval'
  self.priority = 'High' # Valid options = Low | Medium | High

  def self.deliver_to_user(user, school, link)
    exact_target_email_attributes = {
      HTML__espVerificationUrl: "<a href=\"#{link}\">#{link}</a>",
      first_name: user.first_name,
      school_name: school.name
    }
    deliver(user.email, exact_target_email_attributes)
  end

end
require 'addressable/uri'
class OspRejectionEmail < AbstractExactTargetMailer

  self.exact_target_email_key = 'OSP-rejection'
  self.priority = 'High' # Valid options = Low | Medium | High

  def self.deliver_to_user(user, school)
    exact_target_email_attributes = {
      first_name: user.first_name,
      school_name: school.name
    }
    deliver(user.email, exact_target_email_attributes)
  end

end
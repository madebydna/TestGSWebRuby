require 'addressable/uri'
class StudentReviewHasBeenRemovedEmail < AbstractExactTargetMailer

  self.exact_target_email_key = 'school_review_removed_student'
  self.from = {
    address: 'gs-batch@greatschools.org',
    name: 'GreatSchools'
  }
  self.priority = 'High' # Valid options = Low | Medium | High

  def self.deliver_to_user(user, school)
    exact_target_email_attributes = {
      schoolName: school.name
    }

    deliver(user.email, exact_target_email_attributes)
  end

end

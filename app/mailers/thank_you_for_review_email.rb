require 'addressable/uri'
class ThankYouForReviewEmail < AbstractExactTargetMailer

  self.exact_target_email_key = 'review_posted_trigger'
  self.from = {
    address: 'gs-batch@greatschools.org',
    name: 'GreatSchools'
  }
  self.priority = 'High' # Valid options = Low | Medium | High

  def self.deliver_to_user(user, school, school_review_page_url)
    exact_target_email_attributes = {
      HTML__reviewLink: "<a href=\"#{school_review_page_url}\">your review</a>",
      schoolName: school.name
    }

    deliver(user.email, exact_target_email_attributes)
  end

end

# frozen_string_literal: true

class ReviewPublishedMssEmail < AbstractExactTargetMailer
  include Rails.application.routes.url_helpers
  include UrlHelper

  EMAIL_BATCH_SIZE = 50
  self.exact_target_email_key = 'TBD' #TODO
  self.priority = 'Low' # Valid options = Low | Medium | High

  def initialize(school, review_snippet)
    @school = school
    @snippet = review_snippet
  end

  def trigger_email
    school_url = school_reviews_url(@school)
    @school.mss_subscribers.map(&:email).uniq.each_slice(EMAIL_BATCH_SIZE) do |emails|
      ReviewPublishedMssEmail.deliver(emails,
                                      reviewUrl: school_url,
                                      schoolName: @school.name,
                                      reviewSnippet: @snippet)
    end
  end
end
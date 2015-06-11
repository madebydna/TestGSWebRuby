class UserEmailSender
  include Rails.application.routes.url_helpers
  include UrlHelper

 attr_accessor :user

  def initialize(user)
   @user = user
  end


  def send_thank_you_email_for_school(school)
    school_user = SchoolUser.find_by_school_and_user(school, user)
    if send_thank_you_email?(school_user)
      review_url = school_reviews_url(school)
      ThankYouForReviewEmail.deliver_to_user(user, school, review_url)
    end
  end

  def send_thank_you_email?(school_user)
    # Only send thank you email if the saved review is the first active review
    return false if school_user.active_reviews.count != 1
    # Member types: Parent, Teacher & Community Member get email for every first active review
    return true if !school_user.student? && !school_user.principal?
    # Student school member only gets thank you email for first review without comment
    # Student reviews with comment only receive thank you emails if activated by moderator
    return true if school_user.student? && !school_user.active_reviews.first.comment.present?
    # School member identiyfing as principal will not receive email unless review is approved by moderator
    return false if school_user.principal?
  end

end
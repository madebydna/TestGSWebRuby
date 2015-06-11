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
    return true if ( school_user && !school_user.unknown? && school_user.active_reviews.count == 1 )
    false
  end

end
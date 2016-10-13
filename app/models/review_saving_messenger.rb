class ReviewSavingMessenger

  attr_reader :user, :reviews

  def initialize(user, reviews)
    @user = user
    @reviews = reviews
  end

  def run
   { active: one_review_active?, message: message }
  end

  def message
    if unregistered?
      return I18n.t("actions.review.pending_email_verification")
    elsif one_review_active?
      return I18n.t("actions.review.activated")
    elsif moderated?
      return I18n.t("actions.review.pending_moderation")
    else
      GSLogger.error('MISC', nil, {message: "ReviewSavingMessenger received inactive reviews not moderated or pending email verification\nreviews: #{reviews}"})
      return "Your reviews have not been activated"
    end
  end

  def unregistered?
    ! user.email_verified
  end

  def one_review_active?
    reviews.any?(&:active)
  end

  def moderated?
    reviews.any? do |review|
      review.flags.any?(&:active)
    end
  end

end

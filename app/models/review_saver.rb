class ReviewSaver

  attr_accessor :school_user, :review

  def initialize(review, school_user)
    @review = review
    @school_user = school_user
  end

  def existing_review
    @existing_review ||= school_user.find_active_review_by_question_id(review.review_question_id.to_i)
  end

  def save
    old_review = existing_review
    if old_review
      existing_review.deactivate
      unless existing_review.save
        GSLogger.error(:reviews, nil, vars: existing_review.attributes,
                       message: "Unable to deactivate existing review: #{existing_review.errors.first}")
        return false, existing_review
      end
    end
    return review.save, review
  end
end

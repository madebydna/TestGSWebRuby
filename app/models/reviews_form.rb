class ReviewsForm
  include ActiveModel::Model

  attr_accessor :reviews_params, :state, :school_id, :user, :school, :saved_reviews

  validates :state, presence: {message: "Must provide school state"}
  validates :school_id, presence: {message: "Must provide school id"}
  validate :school_found
  validate :validate_reviews_expect_for_unique_active_reviews_validation

  def save
    if valid?
     valid = true
     @saved_reviews = reviews.map do |review|
       review_valid, review = ReviewSaver.new(review, school_user).save
       unless review_valid
        valid = false
       end
       review
     end
     return valid
    end
  end

  def school_user
    @_school_user ||=(
    member =  SchoolUser.find_by_school_and_user(school, user)
    unless member
      member = SchoolUser.new
      member.school = school
      member.user = user
    end
    member
    )
  end

  def reviews
    @_reviews ||= (
      JSON.parse(reviews_params).map do |review_params|
     params =  {
       school_id: school_id,
        state: state,
        user: user
     }
     review, answer = review_params(review_params)
     review =  Review.new(review.merge(params))
     if answer
       review.answers << ReviewAnswer.new(answer)
     end
     review
    end
    )
  end

  def review_params(params)
    review = params.reject{ |k,v| k == "answer_value"}
    answer = params.select{ |k,v| k == "answer_value" }
    return review, answer
  end

  def school
    @_school ||=(
      School.find_by_state_and_id(state, school_id)
    )
  end

  def school_found
    @_school ||= School.find_by_state_and_id(state, school_id)
    unless @_school.present?
      errors.add(:school, "Specified school was not found")
    end
  end

  def hash_result
    {
      reviews: reviews_hash,
      message: reviews_saving_message,
      user_reviews: user_reviews
    }
  end

  def existing_reviews_not_updated
    existing_reviews = school_user.reviews.having_comments.select(&:active)
    review_question_ids_updated = saved_reviews.map(&:review_question_id)
    existing_reviews.reject do |review|
      review_question_ids_updated.include?(review.review_question_id)
    end
  end

  def all_active_reviews
    saved_reviews + existing_reviews_not_updated
  end

  def user_reviews
    UserReviews.new(all_active_reviews, school).build_struct
  end

  def reviews_saving_message
    ReviewSavingMessenger.new(user, saved_reviews).run
  end

  def reviews_hash
    if saved_reviews
      result_reviews = saved_reviews
    else
      result_reviews = reviews
    end
    result_reviews.each_with_object({}) do |review, hash|
      question_key = review.review_question_id.to_s
      hash[question_key] = {
        comment: review.comment,
        answer: review.answer,
      }
      unless review.valid?
        hash[question_key].merge!({errors: review.errors.full_messages})
      end
    end
  end

  def validate_reviews_expect_for_unique_active_reviews_validation
    valid = true
    error_messages = reviews.each_with_object({}) do |review, hash|
      review.disable_unique_active_reviews_validation_temporarily
      valid = review.valid? && valid
      hash[review.review_question_id] = review.errors.full_messages.first
    end
    unless valid
      errors.add(:reviews, error_messages)
    end
  end
end

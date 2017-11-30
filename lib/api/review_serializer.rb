class Api::ReviewSerializer
  attr_reader :review

  def initialize(review)
    @review = review
  end

  def to_hash
    {
      id: review.id,
      comment: review.comment,
      created: review.created,
      user_type: review.user_type,
      answer: review.answer
    }
  end
end

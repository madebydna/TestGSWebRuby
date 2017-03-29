class UserReviews
  include Rails.application.routes.url_helpers

  USER_TYPE_AVATARS = {
    'parent' => 1,
    'student' => 2,
    'principal' => 5,
    'school leader' => 5,
    'teacher' => 4,
    'community member' => 3,
    'unknown' => 3,
    'padre' => 1,
    'estudiante actual' => 2,
    'estudiante' => 2,
    'funcionario de la escuela' => 5,
    'líder de la escuela' => 5,
    'profesor' => 4,
    'miembro de la comunidad' => 3
  }.freeze

  attr_reader :reviews, :school

  def initialize(reviews, school)
    @reviews = reviews.extend(ReviewScoping).extend(ReviewCalculations)
    @school = school
  end

  def self.make_instance_for_each_user(reviews, school)
    reviews.group_by { |review| review.member_id }.
      values.
      map do |user_reviews|
      self.new(user_reviews, school)
    end
  end

  def member_id
    reviews.first[:member_id]
  end

  def user_type
    @_user_type ||= (
      SchoolProfileReviewDecorator.decorate(reviews.first).user_type
    )
  end

  def build_struct
    {}.tap do |hash|
      five_star_review, topical_reviews = partition
      hash["school_user_digest"] = school_user_digest(member_id)
      hash["five_star_review"] = review_to_hash(five_star_review) if five_star_review
      hash["topical_reviews"] = topical_reviews.map { |r| review_to_hash(r) }
      date = most_recent_date
      hash["most_recent_date"] = I18n.l(date, format: "%B %d, %Y")
      hash["user_type_label"] = user_type.gs_capitalize_first
      hash["avatar"] = USER_TYPE_AVATARS[user_type]
      hash["id"] = self.hash
    end
  end

  def school_user_digest(user_id)
    SchoolUserDigest.new(user_id, school).create
  end

  def review_to_hash(review)
    review = SchoolProfileReviewDecorator.decorate(review)
    {
      comment: review.comment,
      topic_label: review.topic_label,
      answer: review.answer.to_s.try(:downcase),
      answer_label: review.answer_label,
      answer_value: review.numeric_answer_value,
      date_published: review.created,
      id: review.id,
      links: {
        flag: flag_review_path(review.id)
      }
    }
  end

  def most_recent_date
    reviews.map(&:created).max
  end

  # Returns five_star_review, rest of reviews
  # five_star_review may return as nil
  def partition
    five_star_reviews = reviews.five_star_rating_reviews
    other_reviews = reviews.non_five_star_rating_reviews
    raise "User has multiple five-star reviews" if five_star_reviews.size > 1
    return five_star_reviews.first, Array.wrap(other_reviews)
  end
end

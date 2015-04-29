module SchoolReviewConcerns
  extend ActiveSupport::Concern

  # returns Topics with questions for school
  def topical_review_question_hash
    filtered_topics = ReviewTopic.includes(:review_questions).find_by_school(self)
    filtered_topics.each_with_object({}) do |topic, hash|
      hash[topic.name] = topic.build_questions_display_array(self)
    end
  end

  # returns an ActiveRecord::Relation
  # used for building a partial query using the most common criteria for getting reviews for a school
  # get active reviews for a school, and eager load school_members.
  # also preload review answers, questions, and topics using ActiveRecord's include method, which will decide itself
  # whether to preload those associations using a join or using a second query (it will probably use a second query)
  #
  # The school members have to be loaded using eager_load, which uses an outer join, since a join is required
  # to get the school members (see the school_member association in review.rb)
  def reviews_scope
    Review.
      active.
        where(school_id: self.id, state: self.state).
          eager_load(:school_member).
          includes(:answers, question: :review_topic)
  end

  # Similar to reviews_scope, but returns only "five star reviews", which are reviews that belong to the
  # "5 star rating" review topic.
  def five_star_review_scope
    reviews_scope.five_star_review
  end

  # Get an ActiveRecord::Relation by calling reviews_scope, order them, and convert to an array
  # It's generally better to call .to_a (or any other method that will cause ActiveRecord to actually send the query
  # to mysql) as late as possible. It's better to iterate over ActiveRecord results using .find_each, since it will
  # batch records in batches of 1000. In this case having over 1000 reviews is currently uncommon, and the benefit
  # here is that we memoize the reviews on the school object, so that future references don't cause any queries.
  def reviews
    @reviews ||= (
      reviews_scope.
        order(created: :desc).
          to_a
    )
  end

  def five_star_reviews
    @five_star_reviews ||= (
      five_star_review_scope.
        order(created: :desc).
          to_a
    )
  end

end
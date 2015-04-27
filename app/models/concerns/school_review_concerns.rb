module SchoolReviewConcerns
  extend ActiveSupport::Concern

  # returns Topics with questions for school
  def topical_review_question_hash
    filtered_topics = ReviewTopic.includes(:review_questions).find_by_school(self)
    filtered_topics.each_with_object({}) do |topic, hash|
      hash[topic.name] = topic.build_questions_display_array(self)
    end
  end

  # def calculate_review_data
  #   SchoolReviews.calc_review_data(all_reviews)
  # end
  #
  # def community_rating
  #   calculate_review_data.seek('rating_averages','overall','avg_score')
  # end

  def reviews_scope
    Review.
      active.
        where(school_id: self.id, state: self.state).
          eager_load(:school_member).
          includes(:answers, question: :review_topic)
  end


  def five_star_review_scope
    reviews_scope.five_star_review
  end

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
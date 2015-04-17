module SchoolReviewConcerns
  extend ActiveSupport::Concern


  # returns Topics with questions for school
  def topical_review_question_hash
    filtered_topics = ReviewTopic.find_by_school(self)
    filtered_topics.each_with_object({}) do |topic, hash|
      hash[topic.name] = topic.build_questions_display_array(self)
    end
  end

  def principal_review
    SchoolRating.fetch_principal_review self
  end

  # group_to_fetch, order_results_by, offset_start, quantity_to_return
  def reviews_filter( options ={} )
    #second parameter is group to filter by leave it as empty string '' for all
    #third parameter is order by - options are
    #   '' empty string is most recent first
    #   'oldest' is oldest first
    #   'rating_top' is by highest rating
    #   'rating_bottom' is by lowest rating
    SchoolRating.fetch_reviews self, group_to_fetch: options[:group_type], order_results_by: options[:order_results_by], offset_start: options[:offset_start], quantity_to_return: options[:quantity_to_return]
  end

  def all_reviews
    @all_reviews ||= reviews.load
  end

  def review_count
    all_reviews.count
  end

  def calculate_review_data
    SchoolReviews.calc_review_data(all_reviews)
  end

  def community_rating
    calculate_review_data.seek('rating_averages','overall','avg_score')
  end

  def reviews
    @reviews ||= (
      Review.
        active.
        where(school_id: self.id, state: self.state).
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

  def five_star_review_scope
    Review.
      active.
      five_star_review.
      where(school_id: self.id, state: self.state).
      includes(:review_answers, question: :review_topic)
  end

end
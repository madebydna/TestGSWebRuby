module SchoolProfiles
  class Reviews
    include Rails.application.routes.url_helpers

    attr_reader :reviews, :school

    def initialize(school)
      @school = school
      @reviews = school.reviews
    end

    def summary
      @_summary ||= (
      OpenStruct.new.tap do |struct|
        struct.number_of_reviews = reviews.size
        struct.number_of_reviews_label = reviews.size == 1 ? 'Review' : 'Reviews'
        struct.average_five_star_rating = 
          reviews.five_star_rating_reviews.average_score.round
        struct.number_of_five_star_rating_reviews = reviews.five_star_rating_reviews.size
        struct.distribution = reviews.five_star_rating_reviews.score_distribution
        struct.topical_review_summary = reviews.topical_review_summary
        struct.topical_review_distributions = reviews.by_topic.each_with_object({}) do |(topic, topical_reviews), hash|
          hash[I18n.db_t(topic)] = topical_reviews.extend(ReviewCalculations).score_distribution
        end
      end)
    end

    def reviews_list
      UserReviews.
        make_instance_for_each_user(reviews.having_comments, school).
        sort_by { |r| r.most_recent_date }.
        reverse.
        map { |user_reviews| user_reviews.build_struct }
    end
  end
end

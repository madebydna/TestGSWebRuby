module SchoolProfiles
  class Reviews
    include Rails.application.routes.url_helpers

    USER_TYPE_AVATARS = {
      'parent' => 1,
      'student' => 2,
      'principal' => 5,
      'teacher' => 4,
      'community member' => 3,
      'unknown' => 3
    }.freeze

    attr_reader :reviews

    def initialize(reviews)
       @reviews = reviews
    end

    def summary
      OpenStruct.new.tap do |struct|
        struct.number_of_reviews = reviews.size
        struct.number_of_reviews_label = reviews.size == 1 ? 'Review' : 'Reviews'
        struct.average_five_star_rating = 
          reviews.five_star_rating_reviews.average_score.round
        struct.number_of_five_star_rating_reviews = reviews.five_star_rating_reviews.size
        struct.distribution = reviews.five_star_rating_reviews.score_distribution
        struct.topical_distribution = reviews.count_by_topic
        struct.topical_review_summary = reviews.topical_review_summary
      end
    end

    def reviews_list
      UserReviews.
        make_instance_for_each_user(reviews.having_comments).
        sort_by { |r| r.most_recent_date }.
        reverse.
        map { |user_reviews| build_user_reviews_struct(user_reviews) }
    end

    def build_user_reviews_struct(user_reviews)
      {}.tap do |hash|
        five_star_review, topical_reviews = user_reviews.partition
        hash['five_star_review'] = review_to_hash(five_star_review) if five_star_review
        hash['topical_reviews'] = topical_reviews.map { |r| review_to_hash(r) }
        date = user_reviews.most_recent_date
        hash['most_recent_date'] = I18n.l(date, format: "%B %d, %Y")
        hash['user_type_label'] = user_reviews.user_type.gs_capitalize_first
        hash['avatar'] = USER_TYPE_AVATARS[user_reviews.user_type]
        hash['id'] = user_reviews.hash
      end
    end

    def review_to_hash(review)
      review = SchoolProfileReviewDecorator.decorate(review)
      {
        comment: review.comment,
        topic_label: review.topic_label,
        answer: review.answer.try(:downcase),
        answer_label: review.answer_label,
        id: review.id,
        links: {
          flag: flag_review_path(review.id)
        }
      }
    end
  end

  class UserReviews
    def self.make_instance_for_each_user(reviews)
      reviews.group_by { |review| review.member_id }.
        values.
        map do |user_reviews|
          user_reviews.extend(ReviewScoping).extend(ReviewCalculations)
          self.new(user_reviews)
      end
    end

    def initialize(reviews)
      @reviews = reviews
    end

    def user_type
      SchoolProfileReviewDecorator.decorate(reviews.first).user_type
    end

    attr_reader :reviews

    def most_recent_date
      reviews.map(&:created).max
    end

    # Returns five_star_review, rest of reviews
    # five_star_review may return as nil
    def partition
      five_star_reviews = reviews.five_star_rating_reviews
      other_reviews = reviews.non_five_star_rating_reviews
      raise 'User has multiple five-star reviews' if five_star_reviews.size > 1
      return five_star_reviews.first, Array.wrap(other_reviews)
    end
  end
end

module SchoolProfiles
  class Reviews

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
      OpenStruct.new.tap do |struct|
        five_star_review, topical_reviews = user_reviews.partition
        struct.five_star_review = five_star_review
        struct.topical_reviews = topical_reviews
        date = user_reviews.most_recent_date
        struct.most_recent_date = I18n.l(date, format: "%B %d, %Y")
        struct.user_type_label = "A #{user_reviews.user_type}"
        struct.avatar = USER_TYPE_AVATARS[user_reviews.user_type]
      end
    end
  end

  class UserReviews
    def self.make_instance_for_each_user(reviews)
      reviews.group_by { |review| review.member_id }.
        values.
        map { |user_reviews| self.new(user_reviews) }
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
      five_star_reviews, other_reviews = 
        reviews.partition do |r|
          # TODO: review should be able to tell you if it is a five-star review
          r.review_question_id.to_s == '1'
        end
      raise 'User has multiple five-star reviews' if five_star_reviews.size > 1
      return five_star_reviews.first, Array.wrap(other_reviews)
    end
  end
end

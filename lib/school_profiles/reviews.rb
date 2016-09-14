module SchoolProfiles
  class Reviews
    USER_TYPE_AVATARS = {
      'parent' => 1,
      'teacher' => 2,
      'student' => 3,
      'principal' => 4,
      'community member' => 5,
      'unknown' => 5
    }.freeze

    attr_reader :school

    def initialize(school)
       @school = school
    end

    def having_comments
      reviews.having_comments
    end

    def reviews
      school.reviews.having_comments
    end

    def reviews_list
      reviews_by_member = reviews.group_by { |review| review.member_id }

      reviews = reviews_by_member.values.sort_by { |r| r.map(&:created).max }.reverse

      reviews.map do |user_reviews|
        OpenStruct.new.tap do |struct|
          five_star_reviews, topical_reviews = 
            user_reviews.partition { |r| r.review_question_id.to_s == '1' }
          struct.five_star_review = five_star_reviews.first
          struct.topical_reviews = topical_reviews
          date = user_reviews.map(&:created).max
          struct.most_recent_date = I18n.l(date, format: "%B %d, %Y")
          struct.user_type_label = "A #{SchoolProfileReviewDecorator.decorate(user_reviews.first).user_type}"
          struct.avatar = USER_TYPE_AVATARS[user_reviews.first.user_type]
        end
      end
    end

  end


end

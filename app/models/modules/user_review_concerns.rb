module UserReviewConcerns
  extend ActiveSupport::Concern

  included do
    # Reviews that this User authored
    has_many :reviews, foreign_key: 'member_id'

    # Review answers that User authored
    has_many :answers, through: :reviews

    # Reviews that this User authored, that are published now
    has_many :published_reviews, -> { published }, class_name: 'Review', foreign_key: 'member_id'

    # Reviews that this User authored, that are flagged now
    has_many :flagged_reviews, -> { reported }, class_name: 'Review', foreign_key: 'member_id'

    # ReviewFlag objects that this User created by reporting a review
    has_many :review_flags, foreign_key: 'member_id', class_name: 'ReviewFlag'

    # Reviews that this User flagged
    has_many :reviews_user_flagged, class_name: 'Review', through: :review_flags, source: :review
  end

  def reviews_for_school(*args)
    Review.find_by_school(*args).unscope(where: :active).where(member_id: self.id).order(created: :desc).includes(:answers)
  end

  def publish_reviews!
    UserReviewPublisher.new(self).publish_reviews_for_new_user!
  end

  def has_active_vote_on_review?(review)
    review_votes.active.map(&:review_id).include?(review.id)
  end

  class UserReviewPublisher
    attr_reader :user

    def initialize(user)
      @user = user
    end

    # Reviews the user wrote that are able to be seen on the site (non-flagged reviews)
    # Includes already-published reviews
    def publishable_reviews
      @publishable_reviews ||= user.reviews.eager_load(:flags)
    end

    # Only one review for an individual school and question can be active at one time
    # Group publishable reviews by school and question
    def publishable_reviews_by_group
      publishable_reviews.group_by do |review|
        [review.school_id, review.state, review.review_question_id]
      end
    end

    def most_recently_created_review(reviews)
      reviews.sort_by(&:created).last
    end

    def reviews_have_active_review?(reviews)
      !! reviews.detect { |review| review.active? }
    end

    def reviews_to_publish_for_new_user
      reviews = []
      publishable_reviews_by_group.values.each do |reviews_for_group|
        unless reviews_have_active_review?(reviews_for_group)
          recent_review = most_recently_created_review(
            reviews_for_group.reject { |r| r.flags.any? }
          )
          reviews << recent_review if recent_review
        end
      end
      reviews
    end

    def publish_reviews_for_new_user!
      reviews_to_publish_for_new_user.each do |review|
        review.activate
        review.save!
      end
      # return reviews that are published now
      reviews_to_publish_for_new_user.select { |review| review.active? }
    end
  end
end

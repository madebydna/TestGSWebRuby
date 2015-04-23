# An enumerable collection of reviews with additional behavior
class SchoolReviews
  include Enumerable # means it can respond to enumerable methods
  extend Forwardable # allows the forwarding, which allows the functions listed below to be defined in this class
  def_delegators :reviews, :each, :each_with_object, :[], :blank?, :present?, :any?, :sum, :count, :select

  attr_reader :school, :review_cache
  attr_writer :review_cache

  include ReviewScoping

  def self.build_from_cache(review_cache, school = nil)
    school_reviews = SchoolReviews.new(school, nil)
    school_reviews.review_cache = review_cache
    school_reviews
  end

  def initialize(school, reviews = nil)
    @school = school
    @reviews = reviews
    @reviews.extend ReviewScoping if @reviews
    @reviews.extend ReviewCalculations if @reviews
  end

  def reviews
    @reviews ||= school.reviews || []
    @reviews.extend ReviewScoping
    @reviews.extend ReviewCalculations
    @reviews
  end

  def average_5_star_rating
    review_cache.try(:star_rating) || five_star_rating_reviews.average_score.round
  end

  def number_of_reviews_with_comments
    review_cache.try(:num_reviews) || reviews.number_with_comments
  end

  def number_of_5_star_ratings
    # We can have reviews for the 5 star rating question that have comments but no actual answer value
    review_cache.try(:num_ratings) || five_star_rating_reviews.count_having_rating
  end

  def five_star_rating_score_distribution
    review_cache.try(:star_counts) || five_star_rating_reviews.score_distribution
  end

  def self.calc_review_data(reviews)
    ReviewCaching.new(reviews).calc_review_data
  end

end
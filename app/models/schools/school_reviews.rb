# An enumerable collection of reviews with additional behavior
#
# Contains methods that return important information about reviews. These methods form the public API of
# SchoolReviews and should be the source of the values that get rendered in view templates
#
# Can be constructed with a review cache object, in which case this class will delagate the above mentioned methods
# to the cache object rather than consulting the school's reviews. If the review cache object doesn't have the
# information that the SchoolReviews instance is being asked for, it will consult the school's reviews
class SchoolReviews
  # Include enumerable methods, so that a SchoolReviews instance itself can be treated like an array of reviews
  include Enumerable
  # Extend Forwardable which defines the def_delagators method. Delegate enumerable methods to underlying reviews array
  extend Forwardable
  def_delegators :reviews, :each, :each_with_object, :[], :blank?, :present?, :any?, :sum, :count, :select

  attr_accessor :review_cache, :reviews_proc

  include ReviewScoping
  include ReviewCalculations

  def reviews
    @reviews ||= reviews_proc.call
  end

  # review_cache is an optional object which contains precomputed values, such as average 5 star rating
  # if provided, this class should use it the data source when being asked for info about reviews
  #
  # reviews_proc is required and will be lazily executed and memoized the first time reviews are required. This makes
  # it the responsibility of the caller to determine the scope/query for the fetching the reviews. It might never
  # be executed if a review_cache was provided and has all the data this object needs
  def initialize(review_cache = nil, &reviews_proc)
    @reviews_proc = reviews_proc
    @review_cache = review_cache
  end

  def number_of_active_reviews
    review_cache.try(:num_reviews) || reviews.size
  end

  def number_of_reviews_with_comments
    reviews.number_with_comments
  end

  def number_of_contributors
    reviews.number_of_distinct_users
  end

  def number_of_5_star_ratings
    # We can have reviews for the 5 star rating question that have comments but no actual answer value
    review_cache.try(:num_ratings) || reviews.five_star_rating_reviews.count_having_numeric_answer
  end

  def average_5_star_rating
    review_cache.try(:star_rating) || reviews.five_star_rating_reviews.average_score.round
  end

  def self.calc_review_data(reviews)
    ReviewCaching.new(reviews).calc_review_data
  end

end
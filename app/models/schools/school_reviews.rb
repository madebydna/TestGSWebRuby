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

  attr_reader :school, :review_cache
  attr_writer :review_cache

  include ReviewScoping

  # Builds a new SchoolReviews instance, giving it a review_cache object and possibly a school
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
    # Questionable: Maybe force the SchoolReviews builder/caller to provide the reviews?
    # If school reviews were not provided to this class, obtain them from the school model
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
    review_cache.try(:num_ratings) || five_star_rating_reviews.count_having_numeric_answer
  end

  def five_star_rating_score_distribution
    review_cache.try(:star_counts) || five_star_rating_reviews.score_distribution
  end

  def self.calc_review_data(reviews)
    ReviewCaching.new(reviews).calc_review_data
  end

end
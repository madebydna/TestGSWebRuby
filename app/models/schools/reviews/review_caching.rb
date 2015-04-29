# This class is acting as an adapter between some code that already existed and being used to cache review hashes
# into school cache, and new ReviewScoping and ReviewCalculations modules that contain behavior for
# breaking apart a big collection of reviews into groups, and performing various calculations on those reviews
#
# This class has methods for building hashes of review_info that have the same structure as the hashes in school_cache
class ReviewCaching
  attr_reader :reviews

  def initialize(reviews)
    reviews.extend ReviewScoping
    reviews.extend ReviewCalculations
    @reviews = reviews
  end

  def review_counts_per_user_type
    {
      all: reviews.count,
      parent: reviews.parent_reviews.count,
      student: reviews.student_reviews.count
    }
  end

  def rating_scores_per_user_type
    rating_averages_per_type = Hashie::Mash.new(
      reviews.by_user_type.each_with_object({}) do |(user_type, reviews), hash|
        hash[user_type.to_sym] = reviews.rating_scores_hash
      end
    )

    rating_averages_per_type[:overall] = reviews.rating_scores_hash
    rating_averages_per_type
  end

  def calc_review_data
    Hashie::Mash.new(
      star_counts: reviews.score_distribution,
      rating_averages: rating_scores_per_user_type,
      review_filter_totals: review_counts_per_user_type
    )
  end
end
class ReviewsCaching::ReviewsSnapshotCacher < Cacher

  CACHE_KEY = 'reviews_snapshot'

  def school_reviews
    @school_reviews ||= (
      school.reviews.extend(ReviewScoping).extend(ReviewCalculations)
    )
  end

  def build_hash_for_cache
    {
        avg_star_rating: school_reviews.five_star_rating_reviews.average_score.round,
        num_ratings: school_reviews.five_star_rating_reviews.count_having_numeric_answer,
        num_reviews: school_reviews.size
    }
  end
  
  def self.listens_to?(data_type)
    :school_reviews == data_type
  end
end
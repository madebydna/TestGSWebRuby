module CachedReviewsSnapshotMethods
  def reviews_snapshot
    cache_data['reviews_snapshot'] || {}
  end

  def star_rating
    reviews_snapshot['avg_star_rating'] || 0
  end

  def num_reviews
    reviews_snapshot['num_reviews'] || 0
  end

  def num_ratings
    reviews_snapshot['num_ratings'] || 0
  end
end
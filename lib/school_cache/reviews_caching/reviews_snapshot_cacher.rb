class ReviewsCaching::ReviewsSnapshotCacher < Cacher

  CACHE_KEY = 'reviews_snapshot'

  def school_reviews
    school.reviews.load
  end

  def review_snapshot
    SchoolReviews.calc_review_data(school_reviews)
  end

  def build_hash_for_cache
    {
        avg_star_rating: review_snapshot.rating_averages.overall.avg_score,
        num_ratings: review_snapshot.rating_averages.overall.counter,
        num_reviews: review_snapshot.review_filter_totals.all,
        most_recent_reviews: most_recent_reviews,
        star_counts: review_snapshot.star_counts
    }
    # Could also just put this whole hash in there...
    # {
    # "star_counts"=>[0, 0, 4, 0, 2, 11],
    # "rating_averages"=>{
    #                     "overall"=>{"avg_score"=>4, "total"=>71, "counter"=>17},
    #                     "principal"=>{"avg_score"=>4, "total"=>44, "counter"=>12},
    #                     "teacher"=>{"avg_score"=>4, "total"=>48, "counter"=>12},
    #                     "parent"=>{"avg_score"=>5, "total"=>54, "counter"=>12}},
    # "review_filter_totals"=>{"all"=>18, "parent"=>13, "student"=>3}}
  end

  def most_recent_reviews(num=2)
    reviews = []
    num.times do |i|
      review = school_reviews[i]
      if review
        review_blob = {
            comments: review.comments,
            posted: review.posted.to_s,
            who: review.who,
            quality: review.overall
        }
        reviews << review_blob
      end
    end
    reviews
    end
end
class ReviewsCaching::ReviewsSnapshotCacher < Cacher

  CACHE_KEY = 'reviews_snapshot'

  def school_reviews
    @school_reviews ||= (
      SchoolProfiles::Reviews.new(school, SchoolProfiles::ReviewQuestions.new(school))
    )
  end

  def build_hash_for_cache
    {
        avg_star_rating: school_reviews.reviews.five_star_rating_reviews.average_score.round,
        num_ratings: school_reviews.reviews.five_star_rating_reviews.count_having_numeric_answer,
        num_reviews: school_reviews.reviews.size,
        reviews: reviews_array
    }
  end

  def reviews_array
    school_reviews.reviews_list.map do |review|
      {
        :avatar => review["avatar"],
        :id => review["id"],
        :topic_label => review["topic_label"],
        :links => {
          :flag => ""
        },
        :topical_reviews => [],
        :most_recent_date => review["most_recent_date"],
        :user_type_label => review["user_type_label"],
        :comment => review["comment"]
      }
    end
  end
  
  def self.listens_to?(data_type)
    :school_reviews == data_type
  end
end

# reviews [
#   {
#     avatar:
#       current_user_reported_reviews: []
# review_reported_callback: func
#     five_star_review: {
#       answer:
#       answer_label:
#       answer_value:
#       comment:
#       date_published:
#       id:
#       links: {
#         flag:
#       }
#       topic_label:
#     }
#     id: (if saved)
#     most_recent_date:
#     school_user_digest:
#     user_type_label:
#     topical_reviews: [
#     {
#      answer:
#        answer_value:
#        comment:
#        date_published:
#        id:
#        links: {
#         flag:
#         }
#        topic_label:
#     }
#     ]
#   }
# ]

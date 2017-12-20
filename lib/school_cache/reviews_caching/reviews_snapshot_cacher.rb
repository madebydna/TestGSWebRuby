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
      five_star_review = review["five_star_review"] || {}
      {
        :avatar => review["avatar"],
        :five_star_review => {
          :answer => five_star_review[:answer],
          :answer_label => five_star_review[:answer_label],
          :answer_value => five_star_review[:answer_value],
          :comment => five_star_review[:comment],
          :date_published => five_star_review[:date_published],
          :id => five_star_review[:id],
          :links => {
            :flag => five_star_review[:links] ? five_star_review[:links][:flag] : nil
          },
          :topic_label => five_star_review[:topic_label],
        },
        # Id is a Reviews class object on which #hash has been called
        :id => review["id"],
        :most_recent_date => review["most_recent_date"],
        :school_user_digest => review["school_user_digest"],
        :topical_reviews => [],
        :user_type_label => review["user_type_label"]
      }
    end
  end

  def five_star_review(review)
    review ? review[attribute.to_sym] : nil
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


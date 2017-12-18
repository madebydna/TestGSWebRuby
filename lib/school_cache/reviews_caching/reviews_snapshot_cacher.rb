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

# Structure of reviews_list
# {"school_user_digest"=>"CKdB87zIG/G4egr3P2k5wA==",
#  "five_star_review"=>
#    {:comment=>
#       "This school a really nice community for kids, parents, and teachers.  It is now the designated elementary school, district-wide, for Berkeley's Dual Immersion Spanish/English program.  The new Principal is great and teachers love their kids and are responsive to parents.  I was skeptical about BUSD at first but really think they do a good job!",
#     :topic_label=>"Overall experience",
#     :answer=>"5",
#     :answer_label=>nil,
#     :answer_value=>"5",
#     :date_published=>"June 03, 2013",
#     :id=>1330329,
#     :links=>{:flag=>"/gsr/reviews/1330329/flag"}},
#  "topical_reviews"=>[],
#  "most_recent_date"=>"June 03, 2013",
#  "user_type_label"=>"Parent",
#  "avatar"=>1,
#  "id"=>4577713082488423709}

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


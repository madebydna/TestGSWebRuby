class ReviewVote < ActiveRecord::Base
  include BehaviorForModelsWithActiveField
  db_magic :connection => :gs_schooldb
  self.table_name = 'helpful_reviews'

  belongs_to :review, inverse_of: :votes
  belongs_to :user, foreign_key: 'member_id'

  validates_uniqueness_of(
    :member_id,
    scope: [:review_id],
    message: 'You have already voted on this review'
  )

  def self.vote_count_by_id(review_ids)
    hash = ReviewVote.select("review_id, Count(*) as count").where(review_id: review_ids).active.group(:review_id)
    hash.inject({}) { |hash, row| hash[row[:review_id]] = row[:count]; hash }
  end

end
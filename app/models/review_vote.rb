class ReviewVote < ActiveRecord::Base
  include BehaviorForModelsWithActiveField
  db_magic :connection => :gs_schooldb
  self.table_name = 'review_votes'

  belongs_to :review, inverse_of: :votes
  belongs_to :user, foreign_key: 'member_id'

  validates_uniqueness_of(
    :member_id,
    scope: [:review_id],
    message: 'You have already voted on this review'
  )

  def self.vote_count_by_id(review_ids)
    # There was a time when anyone could vote on a review without having an account, so some votes have no user
    # For votes with a user, only count ones where user is email verified
    hash = ReviewVote.select("review_id, Count(*) as count").
      joins('left outer join list_member on review_votes.member_id = list_member.id').
      where('(list_member.email_verified = true OR review_votes.member_id is null)').
      where(review_id: review_ids).
      active.group(:review_id)

    hash.inject({}) { |hash, row| hash[row[:review_id]] = row[:count]; hash }
  end

end
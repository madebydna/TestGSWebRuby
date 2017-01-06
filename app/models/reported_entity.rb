class ReportedEntity < ActiveRecord::Base
  db_magic :connection => :community
  self.table_name = 'reported_entity'
  attribute :active, Type::Boolean.new

  scope :active, -> { where(active: 1) }

  attr_accessor :review

  belongs_to :user, foreign_key: :reporter_id

  belongs_to :school_rating, foreign_key: :reported_entity_id

  alias_attribute :type, :reported_entity_type

  def inactive?
    !active?
  end

  def self.from_review(review, reason)
    now = Time.now
    ReportedEntity.new(
      reporter_id: -1,
      reported_entity_type: 'schoolReview',
      reported_entity_id: review.id,
      reason: reason,
      active: 1,
      created: now,
      updated: now
    )
  end

  def self.find_by_reviews(reviews)
    ReportedEntity.where(
      reported_entity_type: %w[schoolReview],
      reported_entity_id: Array.wrap(reviews).map(&:id)
    )
  end

end

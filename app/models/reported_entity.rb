class ReportedEntity < ActiveRecord::Base
  db_magic :connection => :community
  self.table_name = 'reported_entity'


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

end
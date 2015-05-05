class ReviewFlag < ActiveRecord::Base
  include BehaviorForModelsWithActiveField

  self.table_name = 'review_flags'

  db_magic :connection => :gs_schooldb

  attr_accessible :id, :list_member_id, :review_id, :comment, :active, :reason, :created

  belongs_to :user, foreign_key: 'member_id'
  belongs_to :review, inverse_of: :flags

  VALID_REASONS = [
    :'user-reported',
    :'auto-flagged',
    :'bad-language',
    :'student',
    :'held-school',
    :'force-flagged',
    :'blocked-ip',
    :'local-school'
  ].freeze
  USER_REPORTED, AUTO_FLAGGED, BAD_LANGUAGE, STUDENT, HELD_SCHOOL, FORCE_FLAGGED, BLOCKED_IP,
    LOCAL_SCHOOL = *VALID_REASONS

  def reasons=(reasons)
    reasons = Array.wrap(reasons)
    reason_string = reasons.join(',')
    write_attribute(:reason, reason_string)
  end

  def reasons
    reason = read_attribute(:reason)
    reason.split(',')
  end

  validates_presence_of(:review_id, :member_id, :reason)

end
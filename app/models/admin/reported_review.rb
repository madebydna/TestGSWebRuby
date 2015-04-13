class ReportedReview < ActiveRecord::Base
  include BehaviorForModelsWithActiveField

  self.table_name = 'review_flags'

  db_magic :connection => :gs_schooldb

  attr_accessible :id, :member_id, :review_id, :comment, :active, :reason, :created

  belongs_to :user, foreign_key: 'member_id'
  belongs_to :review, inverse_of: :reports
end
class ReportedReview < ActiveRecord::Base
  include BehaviorForModelsWithActiveField

  self.table_name = 'review_reported'

  db_magic :connection => :gs_schooldb

  attr_accessible :id, :list_member_id, :review_id, :comment, :active, :reason, :created

  belongs_to :user, foreign_key: 'list_member_id'
  belongs_to :review, inverse_of: :reports


end
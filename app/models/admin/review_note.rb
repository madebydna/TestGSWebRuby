class ReviewNote < ActiveRecord::Base
  include BehaviorForModelsWithActiveField

  db_magic :connection => :gs_schooldb

  attr_accessible :id, :member_id, :review_id, :notes, :active, :created

  belongs_to :review, inverse_of: :notes
  belongs_to :user, foreign_key: 'member_id'

end
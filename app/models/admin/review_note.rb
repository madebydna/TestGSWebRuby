class ReviewNote < ActiveRecord::Base
  include BehaviorForModelsWithActiveField

  db_magic :connection => :gs_schooldb

  attr_accessible :id, :list_member_id, :review_id, :notes, :active, :created

  belongs_to :review, inverse_of: :notes

end
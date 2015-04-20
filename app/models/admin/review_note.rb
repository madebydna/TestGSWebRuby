class ReviewNote < ActiveRecord::Base
  self.table_name = 'review_notes'
  db_magic :connection => :gs_schooldb

  attr_accessible :id, :member_id, :review_id, :notes, :created

  belongs_to :review, inverse_of: :notes
  belongs_to :user, foreign_key: 'member_id'

  validates_presence_of(:review_id)

end
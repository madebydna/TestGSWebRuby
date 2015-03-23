class Review < ActiveRecord::Base
  self.table_name = 'reviews'

  db_magic :connection => :gs_schooldb

  belongs_to :user, foreign_key: 'member_id'
  belongs_to :school, foreign_key: 'school_id'
  belongs_to :review_question, foreign_key: 'review_question_id'
  has_many :review_answers
  accepts_nested_attributes_for :review_answers, allow_destroy: true

end
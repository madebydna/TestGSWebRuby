class Review < ActiveRecord::Base
  self.table_name = 'reviews'

  db_magic :connection => :gs_schooldb

  belongs_to :user, foreign_key: 'member_id'
  belongs_to :school, foreign_key: 'school_id'
  belongs_to :review_question, foreign_key: 'review_question_id'
  has_many :review_answers
  has_many :notes, class_name: 'ReviewNote', foreign_key: 'review_id', inverse_of: :review
  has_many :reports, class_name: 'ReportedReview', foreign_key: 'review_id', inverse_of: :review

  scope :reported, -> { joins(:reports).where('flags.active' => true) }

  accepts_nested_attributes_for :review_answers, allow_destroy: true

end
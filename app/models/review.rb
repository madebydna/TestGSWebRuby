class Review < ActiveRecord::Base
  self.table_name = 'reviews'

  db_magic :connection => :gs_schooldb

  alias_attribute :member_id, :list_member_id

  belongs_to :user, foreign_key: 'list_member_id'
  belongs_to :school, foreign_key: 'school_id'
  belongs_to :review_question, foreign_key: 'review_question_id'
  has_many :review_answers
  has_many :notes, class_name: 'ReviewNote', foreign_key: 'review_id', inverse_of: :review
  has_many :reports, class_name: 'ReportedReview', foreign_key: 'review_id', inverse_of: :review

  scope :reported, -> { joins(:reports).where('flags.active' => true) }

  accepts_nested_attributes_for :review_answers, allow_destroy: true

  attr_accessible :member_id, :user, :list_member_id, :school_id, :state, :review_question_id, :comment, :user_type

  # TODO: i18n this message
  validates_uniqueness_of :list_member_id, :scope => [:school_id, :state, :review_question_id], message: 'Each question can only be answered once'

  # find_by_school(school: my_school) or find_by_school(school_id: 1, state: 'ca')
  def self.find_by_school(hash)
    school_id = nil
    state = nil

    if hash[:school]
      school_id = hash[:school].id
      state = hash[:school].state
    elsif hash[:state] && hash[:school_id]
      school_id = hash[:school_id]
      state = hash[:state]
    else
      raise(ArgumentError, "Must provide :school or :state and :school_id")
    end

    where(
      school_id: school_id,
      state: state,
      active: true
    )
  end

end
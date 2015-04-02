class Review < ActiveRecord::Base
  include BehaviorForModelsWithActiveField
  self.table_name = 'reviews'

  db_magic :connection => :gs_schooldb

  alias_attribute :member_id, :list_member_id

  belongs_to :user, foreign_key: 'list_member_id'

  belongs_to :review_question, foreign_key: 'review_question_id'
  has_many :review_answers
  has_many :notes, class_name: 'ReviewNote', foreign_key: 'review_id', inverse_of: :review
  has_many :reports, class_name: 'ReportedReview', foreign_key: 'review_id', inverse_of: :review


  accepts_nested_attributes_for :review_answers, allow_destroy: true

  attr_accessible :member_id, :user, :list_member_id, :school_id, :state, :review_question_id, :comment, :user_type

  # TODO: i18n this message
  validates_uniqueness_of :list_member_id, :scope => [:school_id, :state, :review_question_id], message: 'Each question can only be answered once'

  scope :reported, -> { joins(:reports).where('flags.active' => true) }
  scope :selection_filter, ->(show_by_group) { where(:user_type => show_by_group) unless show_by_group == 'all' || show_by_group.nil? || show_by_group.empty? }

  # Commented out to be added back in with Moderation models

  # This have all been replaced by active (check for ussage)
  # scope :disabled, -> { where(status: %w[d pd]) }
  # scope :unpublished, -> { where(status: %w[u pu]) }
  # scope :published, -> { where(:status => ['a', 'p']) }

  #Wating for role table to be created
  # scope :principal, -> { where(who: 'principal') }
  # scope :not_principal, -> { where("who != 'principal'") }
  # scope :belonging_to, ->(user) { where(list_member_id: user.id).order('posted desc') }

  # Update if applicable with new review status
  # scope :posted_asc, -> { order('posted asc') }
  # scope :held, -> { where(status: %w[h ph]) }

  validates :state, presence: true, inclusion: {in: States.state_hash.values.map(&:upcase), message: "%{value} is not a valid state"}
  validates_presence_of :school
  validates_presence_of :user

  validates :comment, length: {
      maximum: 2400,
  }

  validate :comment_minimum_length

  def comment_minimum_length
    # TODO: Internationalize the error string
    if comment.present? && comment.split(' ').length < 15
      errors.add(:comment, "comment is too short (minimum is 15 words")
    end
  end

  def timestamp_attributes_for_create
    super << :created
  end

  def timestamp_attributes_for_update
    super << :updated
  end

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

  def school=(school)
    @school = school
    if school.nil?
      self.school_id = nil
      self.state = nil
    else
      self.school_id = school.id
      self.state = school.state
    end
  end

  def school
    @school ||= School.on_db(self.state.downcase.to_sym).find self.school_id rescue nil
  end

  def uniqueness_attributes
    {
        school_id: school_id,
        state: state,
        member_id: member_id
    }
  end

  def auto_moderate
    alert_word_results = AlertWord.search(comment)

    comment = nil

    if alert_word_results.any?
      comment = 'Review contained '
      if alert_word_results.has_alert_words?
        comment << "warning words (#{ alert_word_results.alert_words.join(',') })"
      end
      if alert_word_results.has_alert_words? && alert_word_results.has_really_bad_words?
        comment << ' and '
      end
      if alert_word_results.has_really_bad_words?
        comment << "really bad words (#{ alert_word_results.really_bad_words.join(',') })"
      end
    end

    if school && school.state == 'DE' && (school.type == 'public' || school.type == 'charter')
      if comment.nil?
        comment = "Review is for GreatSchools Delaware school."
      else
        comment << " Review is for GreatSchools Delaware school."
      end
    end
    if comment
      reported_review = build_reported_review(comment, 'auto-flagged')
      begin
        reported_review.save!
      rescue
        Rails.logger.error "Could not save reported_entity for review with ID #{id}"
      end
    end
  end

  def build_reported_review(comment, reason)
    reported_review = ReportedReview.new
    reported_review.comment = comment
    reported_review.reason = reason
    reported_review.review = self
    reported_review
  end

end
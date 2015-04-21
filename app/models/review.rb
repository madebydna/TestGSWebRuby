class Review < ActiveRecord::Base
  include BehaviorForModelsWithActiveField
  include BehaviorForModelsWithSchoolAssociation
  include Rails.application.routes.url_helpers
  include UrlHelper

  db_magic :connection => :gs_schooldb
  self.table_name = 'reviews'

  attr_accessible :member_id, :user, :member_id, :school_id, :school, :state, :review_question_id, :comment, :review_answers_attributes
  alias_attribute :school_state, :state
  attr_writer :moderated

  belongs_to :user, foreign_key: 'member_id'
  belongs_to :question, class_name:'ReviewQuestion', foreign_key: 'review_question_id'
  has_many :review_answers
  has_many :notes, class_name: 'ReviewNote', foreign_key: 'review_id', inverse_of: :review
  has_many :flags, class_name: 'ReviewFlag', foreign_key: 'review_id', inverse_of: :review
  accepts_nested_attributes_for :review_answers, allow_destroy: true

  scope :flagged, -> { joins(:flags).where('review_flags.active' => true) }
  scope :not_flagged, -> { eager_load(:flags).where( 'review_flags.active = 0 OR review_flags.review_id IS NULL' ) }
  scope :has_inactive_flags, -> { joins(:flags).where('review_flags.active' => false) }
  scope :ever_flagged, -> { joins(:flags) }
  scope :has_comment, -> { where('reviews.comment IS NOT NULL and reviews.comment != ""')}
  scope :selection_filter, ->(show_by_group) { where(:user_type => show_by_group) unless show_by_group == 'all' || show_by_group.nil? || show_by_group.empty? }
  scope :five_star_review, -> { joins(question: :review_topic).where('review_topics.id = 1') }

  # TODO: i18n this message
  validates_uniqueness_of :member_id, :scope => [:school_id, :state, :review_question_id], message: 'Each question can only be answered once'
  validates :state, presence: true, inclusion: {in: States.state_hash.values.map(&:upcase), message: "%{value} is not a valid state"}
  validates_presence_of :school
  validates_presence_of :user
  validates :comment, length: {
      maximum: 2400,
  }
  validate :comment_minimum_length

  before_save :calculate_and_set_active, unless: '@moderated == true'
  after_save :auto_moderate, unless: '@moderated == true'
  after_save :send_thank_you_email_if_published

  def status
    active? ? :active : :inactive
  end

  def comment_minimum_length
    # TODO: Internationalize the error string
    if comment.present? && comment.split(' ').length < 15
      errors.add(:comment, "comment is too short (minimum is 15 words")
    end
  end

  def comment
    string = read_attribute(:comment)
    string.strip if string.present?
  end

  def has_comment?
    comment.present?
  end

  def timestamp_attributes_for_create
    super << :created
  end

  def timestamp_attributes_for_update
    super << :updated
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

    reasons = []
    comment = nil

    if alert_word_results.any?
      reasons << ReviewFlag::BAD_LANGUAGE
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
      reasons << ReviewFlag::LOCAL_SCHOOL
      if comment.nil?
        comment = "Review is for GreatSchools Delaware school."
      else
        comment << " Review is for GreatSchools Delaware school."
      end
    end

    if user_type == 'student'
      reasons << ReviewFlag::STUDENT
    end

    if comment
      reported_review = build_reported_review(comment, reasons)
      begin
        reported_review.save!
      rescue
        Rails.logger.error "Could not save reported_entity for review with ID #{id}"
      end
    end
  end

  def build_reported_review(comment, reasons)
    reported_review = ReviewFlag.new
    reported_review.comment = comment
    reported_review.reasons = reasons
    reported_review.review = self
    reported_review
  end

  def send_thank_you_email_if_published
    if self.active_changed? && self.active?
      review_url = school_reviews_url(school)
      ThankYouForReviewEmail.deliver_to_user(user, school, review_url)
    end
  end

  def calculate_and_set_active
    if user.provisional?  ||
      school.held? ||
      user_type == 'student' ||
      (comment.present? && AlertWord.search(comment).has_really_bad_words?) ||
      PropertyConfig.force_review_moderation? ||
      flags.any?
      #BannedIp.ip_banned?(ip)

      deactivate
    end

    true
  end

  def school_member
    return nil unless school && user
    @school_member ||= SchoolMember.find_by_school_and_user(school, user)
  end

  def user_type
    if school_member
      school_member.user_type
    else
      'unknown'
    end
  end

  def answer
    review_answers.first.answer_value.to_i if review_answers.first
  end


end
class Review < ActiveRecord::Base
  include BehaviorForModelsWithActiveField
  include BehaviorForModelsWithSchoolAssociation
  include Rails.application.routes.url_helpers
  include UrlHelper

  db_magic :connection => :gs_schooldb
  self.table_name = 'reviews'

  attr_accessible :member_id, :user, :member_id, :school_id, :school, :state, :review_question_id, :comment, :answers_attributes
  alias_attribute :school_state, :state
  attr_writer :moderated

  belongs_to :user, foreign_key: 'member_id'
  belongs_to :question, class_name:'ReviewQuestion', foreign_key: 'review_question_id'
  has_many :answers, class_name:'ReviewAnswer', foreign_key: 'review_id', inverse_of: :review
  has_many :notes, class_name: 'ReviewNote', foreign_key: 'review_id', inverse_of: :review
  has_many :flags, class_name: 'ReviewFlag', foreign_key: 'review_id', inverse_of: :review
  accepts_nested_attributes_for :answers, allow_destroy: true

  # See http://pivotallabs.com/rails-associations-with-multiple-foreign-keys/ and comments
  # See the primary key and foreign key of association which will make ActiveRecord join Review to SchoolMember
  # using member_id. But we need two use two more keys. Specify state and school ID in association's condition block
  # Need to check for JoinAssociation:
  # - If school_member is being included/preloaded onto a join, do 1st part of condition using arel_table
  # - If review is a single model, perform 2nd part of condition
  belongs_to :school_member,
             ->(join_or_model) do
               if join_or_model.is_a?(JoinDependency::JoinAssociation)
                 where(state: Review.arel_table[:state], school_id: Review.arel_table[:school_id])
               else
                 where(state: join_or_model.state, school_id: join_or_model.school_id)
               end
             end, foreign_key: 'member_id', primary_key: 'member_id'


  scope :flagged, -> { joins(:flags).where('review_flags.active' => true) }
  scope :not_flagged, -> { eager_load(:flags).where( 'review_flags.active = 0 OR review_flags.review_id IS NULL' ) }
  scope :has_inactive_flags, -> { joins(:flags).where('review_flags.active' => false) }
  scope :ever_flagged, -> { joins(:flags) }
  scope :has_comment, -> { where('reviews.comment IS NOT NULL and reviews.comment != ""')}
  scope :selection_filter, ->(show_by_group) { where(:user_type => show_by_group) unless show_by_group == 'all' || show_by_group.nil? || show_by_group.empty? }
  scope :five_star_review, -> { joins(question: :review_topic).where('review_topics.id = 1') }

  # TODO: i18n this message
  validates_uniqueness_of(
    :member_id,
    scope: [:school_id, :state, :review_question_id],
    conditions: -> { where(active: 1) },
    message: 'Each question can only be answered once'
  )
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

  # TODO: Refactor this into a ReviewFlagBuilder
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

    if school.held?
      reasons << ReviewFlag::HELD_SCHOOL
    end

    if PropertyConfig.force_review_moderation?
      reasons << ReviewFlag::FORCE_FLAGGED
    end

    if comment
      review_flag = build_review_flag(comment, reasons)
      begin
        review_flag.save!
      rescue
        Rails.logger.error "Could not save ReviewFlag for review with ID #{id}"
      end
    end
  end

  def build_review_flag(comment, reasons)
    review_flag = ReviewFlag.new
    review_flag.comment = comment
    review_flag.reasons = reasons
    review_flag.review = self
    review_flag
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

  def user_type
    if school_member
      school_member.user_type
    else
      'unknown'
    end
  end

  def answer
    answers.first.answer_value.to_i if answers.first
  end


end
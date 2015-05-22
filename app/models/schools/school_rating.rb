class SchoolRating < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include UrlHelper
  include UpdateQueueConcerns

  db_magic :connection => :surveys

  self.table_name='school_rating'

  belongs_to :user, foreign_key: 'member_id'
  has_many :reported_entities,-> { where('entity_type = "schoolRating"')}, foreign_key: :reported_entity_id

  scope :selection_filter, ->(show_by_group) { where(:who => show_by_group)  unless show_by_group == 'all' || show_by_group.nil? || show_by_group.empty? }
  scope :limit_number, ->(count) { limit(count) unless count.nil? }
  scope :offset_number, ->(offset_start) { offset(offset_start)  unless offset_start.nil? }
  scope :published, -> { where(:status => ['a', 'p']) }
  scope :provisional, -> { where('length(status) > 1 AND status LIKE ?', 'p%') }
  scope :not_provisional, -> { where('length(status) = 1') }
  scope :quality_decline, -> { where("quality != 'decline'") }
  scope :principal, -> { where(who: 'principal') }
  scope :not_principal, -> { where("who != 'principal'") }
  scope :belonging_to, ->(user) { where(member_id: user.id).order('posted desc') }
  scope :disabled, -> { where(status: %w[d pd]) }
  scope :unpublished, -> { where(status: %w[u pu]) }
  scope :held, -> { where(status: %w[h ph]) }
  scope :flagged, -> { joins("INNER JOIN community.reported_entity ON (reported_entity.reported_entity_type in (\"schoolReview\") and reported_entity.reported_entity_id = school_rating.id and reported_entity.active = 1)") }
  scope :ever_flagged, -> { joins("INNER JOIN community.reported_entity ON reported_entity.reported_entity_type in (\"schoolReview\") and reported_entity.reported_entity_id = school_rating.id") }
  scope :no_rating_and_comments, -> { where("((comments != '' && status != 'a') || quality != 'decline')") }

  attr_accessor :reported_entities
  attr_accessor :count
  attr_writer :moderated

  alias_attribute :review_text, :comments
  alias_attribute :overall, :quality
  alias_attribute :affiliation, :who

  validates :state, presence: true, inclusion: { in: States.state_hash.values.map(&:upcase), message: "%{value} is not a valid state" }
  validates_presence_of :school
  validates_presence_of :user
  validates :who, inclusion: { in: %w(parent teacher other student) }, if: 'school && school.includes_highschool?'
  validates :who, inclusion: { in: %w(parent teacher other) }, unless: 'school && school.includes_highschool?'
  validates_presence_of :overall
  validates :comments, length: {
    maximum: 1200,
  }
  validates :comments, length: {
    minimum: 15,
    tokenizer: lambda { |str| str.split },
  }
  validates_presence_of :ip, on: :create

  before_save :calculate_and_set_status, unless: '@moderated == true'
  before_save :set_processed_date_if_published
  after_save :auto_moderate, unless: '@moderated == true'
  after_save :send_thank_you_email_if_published
  after_save do
    log_review_changed(state, school_id, member_id)
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

  def overall
    # use quality or p_overall(for prek) for star counts and overall
    # score.OM-209
    if quality.present? && quality != 'decline'
      quality
    else
      p_overall
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

  def provisional?
    status.present? && status.length == 2 && status[0] == 'p'
  end

  def disabled?
    status.present? && status[-1] == 'd'
  end
  alias_method :rejected?, :disabled?

  def held?
    status.present? && status[-1] == 'h'
  end

  # Note that a review can be published *and* provisional
  def provisional_published?
    status == 'pp'
  end

  def published?
    status == 'p'
  end

  def unpublished?
    status.present? && status[-1] == 'u'
  end

  def self.order_by_selection(order_selection)
    case order_selection
      when 'oldToNew'
        order("posted ASC")
      when 'ratingsHighToLow'
        order("quality DESC, posted DESC")
      when 'ratingsLowToHigh'
        order("quality ASC, posted DESC")
      else
        order("posted DESC")
    end
  end

  # group_to_fetch, order_results_by, offset_start, quantity_to_return
  def self.fetch_reviews(school, options = {})
    SchoolRating.where(school_id: school.id, state: school.state)
      .selection_filter(options[:group_to_fetch])
      .order_by_selection(options[:order_results_by])
      .limit_number(options[:quantity_to_return])
      .offset_number(options[:offset_start])
      .published
      .not_principal
      .no_rating_and_comments
  end

  # group_to_fetch, order_results_by, offset_start, quantity_to_return
  def self.fetch_principal_review(school, options = {})
    SchoolRating.where(school_id: school.id, state: school.state)
    .published
    .principal
    .first
  end

  def remove_provisional_status!
    if status.present? && status.length > 1 && status[0] == 'p'
      self.status = status[1..-1]
    end
  end

  def publish!
    if provisional?
      self.status = 'pp'
    else
      self.status = 'p'
    end
  end

  def disable!
    if provisional?
      self.status = 'pd'
    else
      self.status = 'd'
    end
  end

  def has_any_bad_language?
    AlertWord.search(review_text).any?
  end

  def calculate_and_set_status
    held = school.held?

    if held
      status = 'h'
    elsif BannedIp.ip_banned?(ip) || who == 'student'
      status = 'u'
    elsif AlertWord.search(review_text).has_really_bad_words?
      status = 'd'
    elsif PropertyConfig.force_review_moderation?
      status = 'u'
    else
      status = 'p'
    end

    if user.provisional?
      status = 'p' + status
    end

    self.status = status
  end

  def auto_moderate
    alert_word_results = AlertWord.search(review_text)

    reason = nil

    if alert_word_results.any?
      reason = 'Review contained '
      if alert_word_results.has_alert_words?
        reason << "warning words (#{ alert_word_results.alert_words.join(',') })"
      end
      if alert_word_results.has_alert_words? && alert_word_results.has_really_bad_words?
        reason << ' and '
      end
      if alert_word_results.has_really_bad_words?
        reason << "really bad words (#{ alert_word_results.really_bad_words.join(',') })"
      end
    end

    if school && school.state == 'DE' && (school.type == 'public' || school.type == 'charter')
      if reason.nil?
        reason = "Review is for GreatSchools Delaware school."
      else
        reason << " Review is for GreatSchools Delaware school."
      end
    end
    if reason
      report = ReportedEntity.from_review(self, reason)

      begin
        report.save!
      rescue
        Rails.logger.error "Could not save reported_entity for review with ID #{id}"
      end
    end
  end

  def set_processed_date_if_published
    if published?
      self.process_date = Time.now.to_s
    end
  end

  def reported?
    Array(reported_entities).any?
  end

  def send_thank_you_email_if_published
    if self.status_changed? && self.published?
      review_url = school_reviews_url(school)
      ThankYouForReviewEmail.deliver_to_user(user, school, review_url)
    end
  end

  def self.by_ip(ips)
    SchoolRating.where(ip: ips)
  end

  private

  def comments_word_count
    errors[:school_rating] << 'Please use at least 15 words in your comment.' if comments.blank? || comments.split.size < 15
  end
end

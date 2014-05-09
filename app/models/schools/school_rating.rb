class SchoolRating < ActiveRecord::Base
  db_magic :connection => :surveys

  self.table_name='school_rating'

  belongs_to :user, foreign_key: 'member_id'

  scope :selection_filter, lambda { |show_by_group| where(:who => show_by_group)  unless show_by_group == 'all' || show_by_group.nil? || show_by_group.empty? }
  scope :limit_number, lambda { |limit_number| limit(limit_number)  unless limit_number.nil? }
  scope :offset_number, lambda { |offset_start| offset(offset_start)  unless offset_start.nil? }
  scope :published, where(:status => ['a', 'p'])
  scope :provisional, where('length(status) > 1 AND status LIKE ?', 'p%')
  scope :not_provisional, where('length(status) = 1')
  scope :quality_decline, where("quality != 'decline'")
  scope :belonging_to, lambda { |user| where(member_id: user.id).order('posted desc') }
  scope :disabled, where(status: %w[d pd])
  scope :unpublished, where(status: %w[u pu])
  scope :held, where(status: %w[h ph])
  scope :flagged, joins("INNER JOIN community.reported_entity ON (reported_entity.reported_entity_type in (\"schoolReview\") and reported_entity.reported_entity_id = school_rating.id and reported_entity.active = 1)")
  scope :ever_flagged, joins("INNER JOIN community.reported_entity ON reported_entity.reported_entity_type in (\"schoolReview\") and reported_entity.reported_entity_id = school_rating.id")

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
  after_save :auto_report_bad_language, unless: '@moderated == true'

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
    else
      status = 'p'
    end

    if user.provisional?
      status = 'p' + status
    end

    self.status = status
  end

  def auto_report_bad_language
    alert_word_results = AlertWord.search(review_text)

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

  def self.find_recent_reviews_in_hub(state_abbr, collection_id, max_reviews = 2)
    # Because our build fails with native sql otherwise
    # https://jenkins.greatschools.org/job/GSWebRubyAlpha%20-%20All%20Specs/2/console
    table = Rails.env.test? ?  "_#{state_abbr.downcase}_test" : "_#{state_abbr.downcase}"

    SchoolRating.joins("JOIN #{table}.school s ON s.id=school_rating.school_id")
                .joins("JOIN #{table}.school_metadata m ON m.school_id=s.id")
                .where("s.active=1 AND m.meta_key='#{School::METADATA_COLLECTION_ID_KEY}'")
                .where("m.meta_value=? AND status='p'", collection_id)
                .where("DATE_SUB(CURDATE(),INTERVAL 90 DAY) <= posted AND school_rating.state=?", state_abbr.upcase)
                .order('posted desc')
                .limit(max_reviews)
                .to_a
                .map { |rating| rating.count = recent_reviews_in_hub_count(rating.state, rating.school.id); rating  }
  end

  def reported?
    Array(reported_entities).any?
  end

  def self.recent_reviews_in_hub_count(state_abbr, school_id)
    cache_key = "recent_reviews_count-state:#{state_abbr}-school_id:#{school_id}"
    Rails.cache.fetch(cache_key, expires_in: ENV_GLOBAL['global_expires_in'].minutes) do
      SchoolRating.where(state: state_abbr, school_id: school_id).published.count
    end
  end

  private

  def comments_word_count
    errors[:school_rating] << 'Please use at least 15 words in your comment.' if comments.blank? || comments.split.size < 15
  end
end

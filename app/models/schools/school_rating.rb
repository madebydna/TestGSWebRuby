class SchoolRating < ActiveRecord::Base
  db_magic :connection => :surveys

  self.table_name='school_rating'

  belongs_to :user, foreign_key: 'member_id'

  scope :selection_filter, lambda { |show_by_group| where(:who => show_by_group)  unless show_by_group == 'all' || show_by_group.nil? || show_by_group.empty? }
  scope :limit_number, lambda { |limit_number| limit(limit_number)  unless limit_number.nil? }
  scope :offset_number, lambda { |offset_start| offset(offset_start)  unless offset_start.nil? }
  scope :published, where(:status => ['a', 'p'])
  scope :provisional, where('length(status) > 1 AND status LIKE ?', 'p%')
  scope :quality_decline, where("quality != 'decline'")
  scope :belonging_to, lambda { |user| where(member_id: user.id) }
  scope :disabled, where(status: %w[d pd])
  scope :unpublished, where(status: %w[u pu])
  scope :held, where(status: %w[h ph])
  scope :reported, joins("INNER JOIN community.reported_entity ON reported_entity.reported_entity_type in (\"schoolReview\") and reported_entity.reported_entity_id = school_rating.id")

  attr_accessor :reported_entities
  attr_accessor :count

  alias_attribute :review_text, :comments
  alias_attribute :overall, :quality
  alias_attribute :affiliation, :who

  validates_presence_of :state
  #validates_format_of :state, with: /#{States.state_hash.values.join '|'}/
  validates_presence_of :school
  validates_presence_of :user
  validates :who, inclusion: { in: %w(parent teacher other student) }, if: 'school && school.includes_highschool?'
  validates :who, inclusion: { in: %w(parent teacher other) }, unless: 'school && school.includes_highschool?'
  validates_presence_of :overall
  validates :comments, length: { minimum: 0, maximum: 1200 }
  validate :comments_word_count
  validates_presence_of :ip

  before_save :calculate_and_set_status, :ensure_all_reviews_moderated, :set_processed_date_if_published
  after_save :auto_report_bad_language

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
    self.status = 'p'
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

  # if the review would otherwise be published (or provisional published), make it unpublished instead, so that it is
  # forced to go through moderation.
  def ensure_all_reviews_moderated
    if status == 'pp'
      self.status = 'pu'
    elsif self.status == 'p'
      self.status = 'u'
    end
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
    cache_key = "recent_reviews-state:#{state_abbr}-collection_id:#{collection_id}-max_reviews:#{max_reviews}"
    Rails.cache.fetch(cache_key, expires_in: ENV_GLOBAL['global_expires_in'].minutes) do
      sql = "select sr.id from surveys.school_rating as sr " +
            "join _" + state_abbr + ".school s on s.id=sr.school_id " +
            "join _" + state_abbr +  ".school_metadata m on m.school_id=s.id " +
            "where s.active=1 and m.meta_key='#{School::METADATA_COLLECTION_ID_KEY}'" +
            " and m.meta_value=" + collection_id.to_s + " and status='p'" +
            " and DATE_SUB(CURDATE(),INTERVAL " + 90.to_s + " DAY) <= posted and sr.state='#{state_abbr.upcase}'" +
            " order by posted desc limit " + max_reviews.to_s
      response = ActiveRecord::Base.connection.raw_connection.query(sql)
      result = []
      response.each do |row|
        review = SchoolRating.find(row[0])
        review.quality = review.quality.to_i
        review.count = recent_reviews_in_hub_count(state_abbr, review.school.id)
        result << review
      end
      result
    end
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
      errors[:school_rating] << 'Please use at least 15 words in your comment.' if comments.split.size < 15
    end
end

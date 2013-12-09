class SchoolRating < ActiveRecord::Base
  db_magic :connection => :surveys

  self.table_name='school_rating'

  belongs_to :user, foreign_key: 'member_id'

  scope :selection_filter, lambda { |show_by_group| where(:who => show_by_group)  unless show_by_group == 'all' || show_by_group.nil? }
  scope :limit_number, lambda { |limit_number| limit(limit_number)  unless limit_number.nil? }
  scope :offset_number, lambda { |offset_start| offset(offset_start)  unless offset_start.nil? }
  scope :published, where(:status => ['a', 'p'])
  scope :provisional, where('length(status) > 1 AND status LIKE ?', 'p%')
  scope :quality_decline, where("quality != 'decline'")
  scope :belonging_to, lambda { |user| where(member_id: user.id) }

  alias_attribute :review_text, :comments
  alias_attribute :overall, :quality


  validates_presence_of :state
  #validates_format_of :state, with: /#{States.state_hash.values.join '|'}/
  validates_presence_of :school
  validates_presence_of :user
  validates_presence_of :status
  validates :comments, length: {minimum: 0, maximum: 1200}
  validate :comments_word_count

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
    begin
      @school ||= School.on_db(self.state.downcase.to_sym).find self.school_id
    rescue
      @school ||= nil
    end
  end

  def uniqueness_attributes
    {
      school_id: school_id,
      state: state,
      member_id: member_id
    }
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
      .quality_decline
  end

  def remove_provisional_status!
    if status.present? && status.length > 1 && status[0] == 'p'
      self.status = status[1..-1]
    end
  end

  def publish!
    self.status = 'p'
  end

  def published?
    self.status == 'p'
  end

  private

  def comments_word_count
    errors[:school_rating] << 'Please use at least 15 words in your comment.' if comments.split.size < 15
  end

end
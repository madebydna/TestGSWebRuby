class ReviewQuestion < ActiveRecord::Base
  include BehaviorForModelsWithActiveField

  self.table_name = 'review_questions'

  db_magic :connection => :gs_schooldb

  belongs_to :review_topic, foreign_key: 'review_topic_id', inverse_of: :review_questions
  has_many :reviews, foreign_key: 'review_question_id', inverse_of: :question

  alias_attribute :school_level_code, :school_level

  scope :active, -> { where(active: true) }

  alias_method :topic, :review_topic

  FIVE_STAR_LABEL_ARRAY = [
    "Terrible",
    "Bad",
    "Average",
    "Good",
    "Great",
  ].freeze

  def overall?
    layout == 'overall_stars'
  end

  def response_array
    str = read_attribute(:responses)
    if str.present?
      return str.split(',')
    else
      []
    end
  end

  def five_star_label_array
    return nil unless overall?
    FIVE_STAR_LABEL_ARRAY
  end

  def response_label_array
    return response_array unless overall? # Avoiding using topic.overall? for performance reasons (extra query to Topic)
    return FIVE_STAR_LABEL_ARRAY
  end

  def chart_response_label_array
    return response_array unless overall?
    response_array.map do |response|
      I18n.t('models.review_answer.stars_label', count: response.to_i)
    end
  end

  def level_code_array
    self.school_level_code.split(',')
  end

  def matches_school?(school)
        school.includes_level_code?(self.level_code_array) && self.school_type.include?(school.type) && self.active
  end


end

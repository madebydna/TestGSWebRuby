class ReviewQuestion < ActiveRecord::Base
  include BehaviorForModelsWithActiveField

  self.table_name = 'review_questions'

  db_magic :connection => :gs_schooldb

  belongs_to :review_topic, foreign_key: 'review_topic_id'

  alias_attribute :school_level_code, :school_level

  scope :active, -> { where(active: true) }

  def response_array
    str = read_attribute(:responses)
    if str.present?
      return str.split(' ')
    else
      []
    end
  end

  def level_code_array
    self.school_level_code.split(',')
  end

  def matches_school?(school)
        school.includes_level_code?(self.level_code_array) && self.school_type.include?(school.type) && self.active
  end

  def display_hash
    {
        id: self.id,
        question: self.question,
        layout: self.layout,
        responses: self.response_array
    }
  end

end
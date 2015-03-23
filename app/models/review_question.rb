class ReviewQuestion < ActiveRecord::Base
  self.table_name = 'review_questions'

  db_magic :connection => :gs_schooldb

  # attr_accessor :question, :responses, :layout

  belongs_to :review_topic, foreign_key: 'review_topic_id'
  scope :active, -> { where(active: true) }

  def response_array
    str = read_attribute(:responses)
    if str.present?
      return str.split(' ')
    else
      []
    end
  end

  def level_code
    self.school_level.split(',')
  end

  def includes_level_and_school_type?(school)
        school.includes_level_code?(self.level_code) && self.school_type.include?(school.type) && self.active
  end

  def display_hash
    {
    question: self.question,
     layout: self.layout,
     responses: self.response_array
    }
  end

  # def review_question_json_config
  #   json = read_attribute(:responses)
  #   if json.present?
  #     begin results = JSON.parse(json,symbolize_names: true)
  #     rescue JSON::ParserError => e
  #       results = {}
  #       Rails.logger.debug "ERROR: parsing JSON Question Config for Review Question ID  #{self.id} \n" +
  #                              "Exception message: #{e.message}"
  #     end
  #     results
  #   else
  #     {}
  #   end
  # end

end
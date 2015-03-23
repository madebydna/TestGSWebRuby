class ReviewTopic < ActiveRecord::Base
  self.table_name = 'review_topics'

  db_magic :connection => :gs_schooldb

  has_many :review_questions

  def self.filter_by_level_code_and_type(school)
    self.select do |review_topic|
        school.includes_level_code?(review_topic.level_code) && review_topic.school_type.include?(school.type)
    end
  end

  def build_questions_display_hash(school)
    filtered_questions = self.review_questions.select do |review_question|
      review_question.includes_level_and_school_type?(school)
    end
    filtered_questions.map { |review_question| review_question.display_hash }
  end

  def level_code
    self.school_level.split(',')
  end

  end
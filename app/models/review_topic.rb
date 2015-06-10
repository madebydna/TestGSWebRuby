class ReviewTopic < ActiveRecord::Base
  include BehaviorForModelsWithActiveField

  self.table_name = 'review_topics'

  db_magic :connection => :gs_schooldb

  has_many :review_questions, inverse_of: :review_topic

  alias_attribute :school_level_code, :school_level

  class ReviewTopicsForSchool
    attr_reader :review_topic, :school

    def initialize(review_topic, school)
      @review_topic = review_topic
      @school = school
    end

    def questions
      @questions ||= (
        review_topic.review_questions.select do |review_question|
          review_question.matches_school?(school)
        end
      )
    end
  end

  def self.find_by_school(school)
    # TODO: convert to straight SQL
    active.to_a.select do |review_topic|
      # Return true if any items in intersection between school and review topic level code
      school.includes_level_code?(review_topic.level_code_array) && review_topic.school_type.include?(school.type)
    end
  end

  def build_questions_display_array(school)
    create_review_topics_for_school(school).questions
  end

  def create_review_topics_for_school(school)
    ReviewTopicsForSchool.new(self, school)
  end

  def level_code_array
    self.school_level_code.split(',')
  end

  def overall?
    name == 'Overall'
  end

  def first_question
    review_questions.first
  end

end

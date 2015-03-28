class ReviewTopic < ActiveRecord::Base
  self.table_name = 'review_topics'

  db_magic :connection => :gs_schooldb

  has_many :review_questions

  class ReviewTopicsForSchool
    attr_reader :review_topic, :school

    def initialize(review_topic, school)
      @review_topic = review_topic
      @school = school
    end

    def questions
      @questions ||= (
        review_topic.review_questions.select do |review_question|
          review_question.includes_level_and_school_type?(school)
        end
      )
    end

    def display_hash
      # questions_matching_school(school).map { |review_question| review_question.display_hash }
      @display_hash ||= questions.map(&:display_hash)
    end
  end

  def self.find_by_school(school)
    # TODO: convert to straight SQL
    all.select do |review_topic|
      # Return true if any items in intersection between school and review topic level code
      school.includes_level_code?(review_topic.level_code) && review_topic.school_type.include?(school.type)
    end
  end

  def build_questions_display_hash(school)
    # questions_matching_school(school).map { |review_question| review_question.display_hash }
    create_review_topics_for_school(school).display_hash
  end

  def create_review_topics_for_school(school)
    ReviewTopicsForSchool.new(self, school)
  end

  def level_code
    self.school_level.split(',')
  end

end


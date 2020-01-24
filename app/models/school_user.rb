class SchoolUser < ActiveRecord::Base
  self.table_name = 'school_members'

  module Affiliation
    PARENT = :parent
    TEACHER = :teacher
    STUDENT = :student
    PRINCIPAL = :principal
    COMMUNITY_MEMBER = :'community member'
    UNKNOWN = :unknown
  end

  VALID_AFFILIATIONS = [
    Affiliation::PARENT,
    Affiliation::TEACHER,
    Affiliation::STUDENT,
    Affiliation::PRINCIPAL,
    Affiliation::COMMUNITY_MEMBER,
    Affiliation::UNKNOWN,
  ].freeze

  include BehaviorForModelsWithSchoolAssociation

  # OSP stuff that happens between a user and a school
  include SchoolUserOspConcerns

  db_magic :connection => :gs_schooldb

  belongs_to :user, foreign_key: 'member_id'

  attr_accessible :user_type

  alias_attribute :school_state, :state

  validates_presence_of :user_type
  validates_inclusion_of :user_type, :in => VALID_AFFILIATIONS.map(&:to_s)

  after_initialize :initialize_attributes

  scope :by_state, -> (state) { where(state: state) }

  def initialize_attributes
    if new_record?
      self.user_type = Affiliation::UNKNOWN if read_attribute(:user_type).nil?
    end
  end

  def self.build_unknown_school_user(school, user)
    school_user = new
    school_user.school = school
    school_user.user = user
    school_user
  end

  def self.find_by_school_and_user(school, user)
    raise ArgumentError.new('Must provide school and user') unless school && user
    find_by(state: school.state, school_id: school.id, member_id: user.id)
  end

  VALID_AFFILIATIONS.each do |type|
    method_name = "#{type.to_s.gsub(' ','_')}?"
    define_method method_name do
      user_type == type
    end
  end
  alias_method :school_leader?, :principal?

  # Returns all reviews the user wrote for the school
  def reviews
    @reviews ||= user.reviews_for_school(school: school).to_a
    @reviews.extend ReviewScoping
  end

  def deactivate_reviews!
    reviews.each do |review|
      review.deactivate
      unless review.save
        message = "Error(s) occurred while attempting to deactivate review #{review.id}"
        message << " for user #{school_user.user.id}. review.errors: #{review.errors.full_messages}"
        Rails.logger.error(message)
        end
      end
    end

  def handle_saved_reviews_for_students_and_principals
    deactivate_reviews_with_comments! if student?
    if principal?
      remove_review_answers!
      deactivate_reviews! if !approved_osp_user?
    end
  end

  def remove_review_answers!
    reviews.each do |review|
      review.answers.destroy_all
    end
  end

  def deactivate_reviews_with_comments!
    reviews.having_comments.each do |review|
      review.deactivate
      unless review.save
        message = "Error(s) occurred while attempting to deactivate review #{review.id}"
        message << " for user #{school_user.user.id}. review.errors: #{review.errors.full_messages}"
        Rails.logger.error(message)
      end
    end
  end

  def user_type
    type = read_attribute(:user_type).try(:to_sym)
    type = Affiliation::UNKNOWN unless VALID_AFFILIATIONS.include?(type)
    type
  end

  # Returns active reviews the user wrote for the school
  def active_reviews
    reviews.select(&:active?)
  end

  def find_by_question(question)
    reviews.find do |review|
      review.question == question
    end
  end

  def find_active_review_by_question_id(question_id)
    active_reviews.find do |review|
      review.review_question_id == question_id.to_i
    end
  end

  # Does not consider active vs inactive reviews
  def first_unanswered_topic
    (ReviewTopic.active.to_a - reviews.map(&:topic)).first
  end

  def self.make_from_esp_membership(esp_membership)
    if esp_membership
      criteria = {
        member_id: esp_membership.member_id,
        state: esp_membership.state,
        school_id: esp_membership.school_id
      }
      school_user = SchoolUser.find_by(criteria) || SchoolUser.new(criteria, without_protection: true)
      if school_user.new_record?
        school_user.user_type = 'principal'
        school_user.save!
      end
    else
      raise 'given esp_membership cannot be nil'
    end
  end

end

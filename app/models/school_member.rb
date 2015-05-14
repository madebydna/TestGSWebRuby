class SchoolMember < ActiveRecord::Base
  include BehaviorForModelsWithSchoolAssociation

  db_magic :connection => :gs_schooldb

  belongs_to :user, foreign_key: 'member_id'

  attr_accessible :user_type

  alias_attribute :school_state, :state

  def self.build_unknown_school_member(school, user)
    school_member = new
    school_member.school = school
    school_member.user = user
    school_member.user_type = 'unknown'
    school_member
  end

  def self.find_by_school_and_user(school, user)
    raise ArgumentError.new('Must provide school and user') unless school && user
    find_by(state: school.state, school_id: school.id, member_id: user.id)
  end

  # Returns all reviews the user wrote for the school
  def reviews
    @reviews ||= user.reviews_for_school(school: school).to_a
  end

  def user_type
    read_attribute(:user_type) || 'unknown'
  end

  # Returns active reviews the user wrote for the school
  def active_reviews
    reviews.select(&:active?)
  end

  def principal?
    user_type == 'principal'
  end
  alias_method :school_leader?, :principal?

end
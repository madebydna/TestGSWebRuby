class SchoolMember < ActiveRecord::Base
  include BehaviorForModelsWithSchoolAssociation

  db_magic :connection => :gs_schooldb

  belongs_to :user, foreign_key: 'member_id'

  attr_accessible :user_type

  alias_attribute :school_state, :state

  def self.find_by_school_and_user(school, user)
    raise ArgumentError.new('Must provide school and user') unless school && user
    find_by(state: school.state, school_id: school.id, member_id: user.id)
  end

  # Returns all reviews the user wrote for the school
  def reviews
    @reviews ||= user.reviews_for_school(school: school).to_a
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
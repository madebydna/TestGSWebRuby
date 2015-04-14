class SchoolMember < ActiveRecord::Base
  include BehaviorForModelsWithSchoolAssociation

  db_magic :connection => :gs_schooldb

  belongs_to :user

  attr_accessible :user_type

  def self.find_by_school_and_user(school, user)
    raise ArgumentError.new('Must provide school and user') unless school && user
    find_by(state: school.state, school_id: school.id, member_id: user.id)
  end
end
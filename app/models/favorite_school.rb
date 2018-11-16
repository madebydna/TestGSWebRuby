class FavoriteSchool < ActiveRecord::Base

  self.table_name = 'list_msl'

  db_magic :connection => :gs_schooldb

  belongs_to :user, foreign_key: 'member_id'

  def self.build_for_school(school)
    favorite_school = new

    favorite_school.state = school.state
    favorite_school.school_id = school.id
    favorite_school.list = ['msl', school.level_code.presence].compact.join(',')
    favorite_school.updated = Time.now

    favorite_school
  end

  def self.saved_school_list(user_id)
    if user_id
      schools = FavoriteSchool.where(member_id: user_id)
      schools.map { |school| school&.school_key }
    else
      []
    end
  end

  def self.create_saved_school_instance(school, user_id)
    saved_school = new
    saved_school.state = school.state
    saved_school.school_id = school.id
    saved_school.list = ['msl', school.level_code.presence].compact.join(',')
    saved_school.updated = Time.now
    saved_school.member_id = user_id

    saved_school
  end

  def school
    School.find_by_state_and_id(state, school_id)
  end
  
  def school_key
    [self.state.downcase, self.school_id]
  end
end
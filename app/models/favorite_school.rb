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
    user = User.find_by(id: user_id)
    if user
      schools = FavoriteSchool.where(member_id: user.id)
      schools.map { |school| school&.parses_school }
    else
      []
    end
  end

  def self.persist_saved_school(school, user_id)
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
  
  def parses_school
    [self.state.downcase, self.school_id]
  end
end
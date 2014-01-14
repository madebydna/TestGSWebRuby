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

  def school
    begin
      School.on_db(state.downcase.to_sym).find school_id
    rescue

    end
  end

end
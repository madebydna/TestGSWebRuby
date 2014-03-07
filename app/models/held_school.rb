class HeldSchool < ActiveRecord::Base

  self.table_name = 'held_school'

  db_magic :connection => :gs_schooldb

  attr_accessible :school_id, :state, :notes

  def school
    School.on_db(state.downcase.to_sym).find school_id rescue nil
  end

  def school=(school)
    self.school_state = school.state
    self.school_id = school.id
  end

end
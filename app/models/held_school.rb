class HeldSchool < ActiveRecord::Base

  self.table_name = 'held_school'

  db_magic :connection => :gs_schooldb

  attr_accessible :school_id, :state, :notes, :active

  validates_presence_of :school_id

  def self.on_hold(state, school_id)
    HeldSchool.where(state: state, school_id: school_id, active: 1).first
  end

  def remove_hold
    self.update(active: 0)
  end

  def school
    School.on_db(state.downcase.to_sym).find school_id rescue nil
  end

  def school=(school)
    self.school_state = school.state
    self.school_id = school.id
  end

  def self.has_school?(school)
    HeldSchool.exists?(school_id: school.id, state: school.state)
  end

end
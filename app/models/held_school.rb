class HeldSchool < ActiveRecord::Base

  self.table_name = 'held_school'

  db_magic :connection => :gs_schooldb

  attr_accessible :school_id, :state, :notes, :active, :placed_on_hold_at

  validates_presence_of :school_id

  scope :active, -> { where(active: true) }
  scope :with_school_record, -> { joins("INNER JOIN school_records on school_records.school_id = held_school.school_id AND school_records.state = held_school.state")}

  def remove_hold
    self.update(active: 0)
  end

  def school
    SchoolRecord.where(state: state, school_id: school_id).first
  end

  def school=(school)
    self.state = school.state
    self.school_id = school.school_id
  end

  def self.active_hold?(school)
    HeldSchool.exists?(school_id: school.id, state: school.state, active: 1)
  end

  def self.all_active_with_school(order_by:, order_dir:, page:, per_page:)
    active.select("held_school.*, school_records.name AS school_name").
      with_school_record.
      order("#{order_by} #{order_dir}").
      page(page).
      per(per_page)
  end

end
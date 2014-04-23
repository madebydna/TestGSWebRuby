class SchoolCache < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'school_cache'
  attr_accessible :name, :school_id, :state, :value, :updated

  def self.for_school(name, school_id, state)
    SchoolCache.where(name: name, school_id: school_id, state: state).first()
  end
end

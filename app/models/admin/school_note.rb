class SchoolNote < ActiveRecord::Base
  self.table_name = 'school_notes'
  alias_attribute :school_state, :state
  include BehaviorForModelsWithSchoolAssociation

  db_magic :connection => :gs_schooldb

  attr_accessible :id, :member_id, :school_id, :state, :notes, :created

end
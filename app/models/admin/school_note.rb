class SchoolNote < ActiveRecord::Base
  include BehaviorForModelsWithActiveField
  alias_attribute :school_state, :state
  include BehaviorForModelsWithSchoolAssociation

  db_magic :connection => :gs_schooldb
  attr_accessible :id, :member_id, :school_id, :school_state, :notes, :active, :created
end
class State < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'state'
  attr_accessible :state, :local, :tier, :tier_week_commitment
  has_many :admin_data_load_schedules, foreign_key: 'state'
end

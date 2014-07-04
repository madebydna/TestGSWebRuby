class TestProficiencyBand < ActiveRecord::Base
  self.table_name = 'TestProficiencyBand'
  db_magic :connection => :gs_schooldb
  attr_accessible :group_id, :name
end

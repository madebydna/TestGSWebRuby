class State < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'state'
end

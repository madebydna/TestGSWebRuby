class User < ActiveRecord::Base
  self.table_name = 'list_member'

  db_magic :connection => :gs_schooldb
end

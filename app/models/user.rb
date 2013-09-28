class User < ActiveRecord::Base
  self.table_name = 'list_member'

  octopus_establish_connection(:adapter => "mysql2", :database => "gs_schooldb")
end

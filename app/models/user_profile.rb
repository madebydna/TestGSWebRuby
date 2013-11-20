class UserProfile < ActiveRecord::Base
  self.table_name = 'user_profile'
  db_magic :connection => :gs_schooldb

  belongs_to :user

end
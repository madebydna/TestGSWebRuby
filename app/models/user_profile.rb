class UserProfile < ActiveRecord::Base
  self.table_name = 'user_profile'
  db_magic :connection => :gs_schooldb

  belongs_to :user

  def active
    read_attribute(:active) == "\x01" ? true : false
  end
  def active?
    active == true
  end

end
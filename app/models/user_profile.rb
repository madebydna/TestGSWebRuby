class UserProfile < ActiveRecord::Base
  self.table_name = 'user_profile'
  db_magic :connection => :gs_schooldb

  belongs_to :user

  attr_accessible :active

  def active
    read_attribute(:active) == "\x01" ? true : false
  end
  def active?
    active == true
  end

end
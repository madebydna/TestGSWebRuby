class UserProfile < ActiveRecord::Base
  self.table_name = 'user_profile'
  db_magic :connection => :gs_schooldb
  attr_accessible :city, :state


  belongs_to :user

  def active
    read_attribute(:active) == "\x01" ? true : false
  end
  def active?
    active == true
  end

  def update_locale_info(state,city)
      UserProfile.update_all({:state => state,:city => city})
  end

end
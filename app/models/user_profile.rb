class UserProfile < ActiveRecord::Base
  self.table_name = 'user_profile'
  db_magic :connection => :gs_schooldb

  belongs_to :user, foreign_key: 'member_id'

  before_save :update_timestamps

  def active
    read_attribute(:active) == "\x01" ? true : false
  end
  def active?
    active == true
  end

  def update_and_save_locale_info(state,city)

    self.city = city
    self.state = state
    self.save
  end

  def update_timestamps

    now = Time.now
    self.created = now if new_record?
    self.updated = now
  end

end
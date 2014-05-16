class EspResponse < ActiveRecord::Base
  self.table_name = 'esp_response'
  include StateSharding

  attr_accessible :response_key, :response_value, :member_id, :esp_source, :active, :school_id

  scope :active, where("active = 1")

  def school=(school)
    self.school_id = school.id
  end

  def user=(user)
    self.member_id = user.id
  end

end

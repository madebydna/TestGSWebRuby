class EspResponse < ActiveRecord::Base
  self.table_name = 'esp_response'
  include StateSharding

  attr_accessible :response_key, :response_value, :member_id, :esp_source, :active, :school_id, :created

  scope :active, -> { where(active: 1) }

  def school=(school)
    self.school_id = school.id
  end

  def user=(user)
    self.member_id = user.id
  end

  def self.new_from_esp_response_update(esp_response_update)
    esp_response = EspResponse.new
    esp_response.attributes = (
        esp_response_update.attributes.merge(
            {
                created: esp_response_update.created,
                esp_source: esp_response_update.esp_source,
                member_id: esp_response_update.member_id,
                response_value: esp_response_update.value
            }
        )
    )
    esp_response
  end

  def active=(value)
    if value == true || value == 1
      write_attribute(:active, 1)
    else
      write_attribute(:active, 0)
    end
  end


end

class Role < ActiveRecord::Base
  self.table_name = 'role'

  db_magic :connection => :gs_schooldb

  def self.esp_superuser
    where(quay: 'ESP_SUPERUSER').first
  end

end

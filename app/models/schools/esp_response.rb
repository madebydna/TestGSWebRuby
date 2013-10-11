class EspResponse < ActiveRecord::Base
  self.table_name = 'esp_response'
  include StateSharding

end

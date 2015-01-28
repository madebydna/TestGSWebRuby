class County < ActiveRecord::Base
  self.table_name = 'county'

  db_magic :connection => :us_geo
end
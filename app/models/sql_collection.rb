class SqlCollection < ActiveRecord::Base
  self.table_name = 'collections'

  db_magic :connection => :gs_schooldb

  has_many :hub_city_mapping
end
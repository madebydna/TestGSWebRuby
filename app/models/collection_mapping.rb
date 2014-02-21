class CollectionMapping < ActiveRecord::Base
  self.table_name = 'hub_city_mapping'
  db_magic :connection => :gs_schooldb

  attr_accessible :city, :state
end

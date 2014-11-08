class NearbyDistrict < ActiveRecord::Base
  self.table_name = 'NearbyDistrict'
  db_magic :connection => :gs_schooldb


end

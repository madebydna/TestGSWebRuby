class DistrictTandemResults < ActiveRecord::Base
  self.table_name = 'district_tandem_results'
  db_magic :connection => :gs_schooldb

  attr_accessible :state, :district_id, :district_name, :nces, :results, :status 
end

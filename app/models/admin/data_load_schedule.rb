class Admin::DataLoadSchedule < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'data_load_schedule'

  attr_accessible :state,:description,:load_type,:year_to_load,:released,:acquired,:live_by,:updated,:updated_by
end

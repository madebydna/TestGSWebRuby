class Admin::DataLoadSchedule < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'data_load_schedule'

  attr_accessible :state,:description,:load_type,:year_to_load,:released,:acquired,:live_by,:updated,:updated_by

  def live_by_month
    live_by = self.live_by
    if live_by.strftime("%d").to_i < 15
      return "#{live_by.strftime("%B")} 1"
    else
      return "#{live_by.strftime("%B")} 15"
    end
  end
end

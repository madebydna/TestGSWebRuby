class Admin::DataLoadSchedule < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'data_load_schedule'

  attr_accessible :state, :description,:load_type,:year_on_site,:year_to_load,:released,:acquired,:live_by,:complete, :status, :updated,:updated_by

  scope :complete, where('complete = 1')
  scope :incomplete, where('complete = 0')

  belongs_to :state_attribute, foreign_key: 'state', class_name: 'State'

  before_save do
    if self.load_type =~ /osp/i
      self.load_type.upcase!
    else
      self.load_type = self.load_type.titleize
    end
  end

  def live_by_month
    date = self.live_by
    if date
      if date.strftime("%d").to_i > 15
        return "#{date.strftime("%B")} 1"
      else
        date -= 1.month
        return "#{date.strftime("%B")} 15"
      end
    end
  end

  def released_month
    date = self.released
    if date
      if date.strftime("%d").to_i < 15
        return "#{date.strftime("%B")} 1"
      else
        return "#{date.strftime("%B")} 15"
      end
    end
  end

  protected

  def date_field_to_month(date,options={})
    if date
      if date.strftime("%d").to_i > 15
        return "#{date.strftime("%B")} 1"
      else
        date -= 1.month
        return "#{date.strftime("%B")} 15"
      end
    end
  end
end

class LeadGen < ActiveRecord::Base
  self.table_name = 'lead_gen'

  db_magic :connection => :gs_schooldb

  attr_accessible :campaign, :full_name, :email, :phone, :grade_level

  validates_presence_of :campaign
end
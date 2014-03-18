class PropertyConfig < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'property'

  def self.sweepstakes?
    PropertyConfig.where(quay: 'sweepstakes').first.value == 'true'
  end
end
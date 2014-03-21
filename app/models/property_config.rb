class PropertyConfig < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'property'

  def self.sweepstakes?
    pc_sweepstakes = PropertyConfig.where(quay: 'sweepstakes')
    pc_sweepstakes.present? ? pc_sweepstakes.first.value == 'true' : false
  end
end
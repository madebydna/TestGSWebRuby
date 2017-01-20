class BpCensus < ActiveRecord::Base
  self.table_name = 'bp_census'
  self.inheritance_column = 'Place_type'

  db_magic :connection => :us_geo

  alias_attribute :zip, :Zip
  alias_attribute :lat, :Lat
  alias_attribute :lon, :Lon
  alias_attribute :name, :Name

  def self.discriminate_class_for_record(record)
    if record[inheritance_column].downcase == 'zi'
      BpZip
    else
      BpCensus
    end
  end

  def state
    self.State ? self.State.downcase : nil
  end
end
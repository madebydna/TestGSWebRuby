class TestDataType < ActiveRecord::Base
  self.table_name = 'TestDataType'
  db_magic :connection => :gs_schooldb
  attr_accessible :description, :display_name, :display_type, :name, :type
  has_many :test_data_sets, class_name: 'TestDataSet', foreign_key: 'data_type_id'
  #bad_attribute_names :type
  #self.inheritance_column = nil
  self.inheritance_column = :_type_disabled
  def self.by_id(data_type_ids)
    begin
      TestDataType.find(data_type_ids)
    rescue
      Rails.logger.debug "Could not locate TestDataType for id #{data_type_ids}"
    end
  end


  def self.city_rating_data_type_ids
    { "mi" => [198, 199, 200, 201]}
  end

  def self.state_rating_data_type_ids
    { "mi" => [197]}
  end

  def self.gs_rating_data_type_ids
    [164, 165, 166]
  end
end

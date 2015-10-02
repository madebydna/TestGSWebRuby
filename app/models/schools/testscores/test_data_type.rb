class TestDataType < ActiveRecord::Base
  self.table_name = 'TestDataType'
  db_magic :connection => :gs_schooldb
  attr_accessible :description, :display_name, :display_type, :name, :type
  has_many :test_data_sets, class_name: 'TestDataSet', foreign_key: 'data_type_id'
  #bad_attribute_names :type
  #self.inheritance_column = nil
  self.inheritance_column = :_type_disabled

  def self.by_ids(data_type_ids)
    begin
      TestDataType.where(id: data_type_ids).group_by(&:id)
    rescue
      Rails.logger.debug "Could not locate TestDataType for id #{data_type_ids}"
    end
  end

  def self.description_description_hash
    Rails.cache.fetch("TestDataType/description_description_hash", expires_in: 5.minutes) do
      all.inject({}) { |hash, tdt| hash[tdt.display_name] = tdt.display_name; hash }
    end
  end

end

class TestDataSchoolValue < ActiveRecord::Base
  self.table_name = 'TestDataSchoolValue'
  include StateSharding
  attr_accessible :active, :data_set_id, :number_tested, :school_id, :value_float, :value_text
  belongs_to :test_data_set, :class_name => 'TestDataSet', foreign_key: 'data_set_id'

  scope :active, where(active: 1)
  def self.for_school school, data_set_ids
    TestDataSchoolValue.on_db(school.shard).active.where(data_set_id: data_set_ids, school_id: school.id)
  end
end

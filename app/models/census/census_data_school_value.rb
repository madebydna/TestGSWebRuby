class CensusDataSchoolValue < ActiveRecord::Base
  self.table_name = 'census_data_school_value'

  belongs_to :school, foreign_key: 'school_id'
  belongs_to :census_data_set, :class_name => 'CensusDataSet', foreign_key: 'data_set_id'

  scope :having_data_set, lambda { |data_set|
    where(data_set_id: data_set.id)
  }

end

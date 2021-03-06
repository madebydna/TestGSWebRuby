class CensusDataSchoolValue < ActiveRecord::Base
  self.table_name = 'census_data_school_value'

  include CensusValueConcerns
  include StateSharding

  belongs_to :school, foreign_key: 'school_id'
  belongs_to :census_data_set, :class_name => 'CensusDataSet', foreign_key: 'data_set_id'

  scope :having_data_sets, ->(data_sets) {
    where(data_set_id: Array(data_sets.map(&:id)))
  }

  default_scope -> { where(active: true) }
end

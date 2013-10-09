class CensusBreakdown < ActiveRecord::Base
  attr_accessible :datatype_id, :description

  has_many :census_data_sets, :class_name => 'CensusDataSet', foreign_key: 'breakdown_id'

  def data_type_id
    @datatype_id
  end

end

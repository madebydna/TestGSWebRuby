class CensusDataStateValue < ActiveRecord::Base
    self.table_name = 'census_data_state_value'

    belongs_to :census_data_set, :class_name => 'CensusDataSet', foreign_key: 'data_set_id'

end

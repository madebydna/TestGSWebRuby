class TestDataSet < ActiveRecord::Base
  self.table_name = 'TestDataSet'
  attr_accessible :active, :breakdown_id, :data_type_id, :display_target, :grade, :level_code, :proficiency_band_id, :school_decile_tops, :subject_id, :year
end

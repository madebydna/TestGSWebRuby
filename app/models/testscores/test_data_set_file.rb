class TestDataSetFile < ActiveRecord::Base
  octopus_establish_connection(:adapter => 'mysql2', :database => 'gs_schooldb')
  self.inheritance_column = nil
  self.table_name = 'TestDataSetFile'
  attr_accessible :data_file_id, :data_set_id, :school_type, :state, :type

  def self.get_valid_data_set_ids(data_set_ids = [])
    @results = TestDataSetFile.where("state = 'ca' and type like '%school%'
                           and school_type like '%public%'
                           and data_set_id in (?)", data_set_ids)

    @results.pluck(:data_set_id)
  end
end


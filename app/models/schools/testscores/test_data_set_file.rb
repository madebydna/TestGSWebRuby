class TestDataSetFile < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.inheritance_column = nil
  self.table_name = 'TestDataSetFile'
  attr_accessible :data_file_id, :data_set_id, :school_type, :state, :type

  def self.get_valid_data_set_ids(data_set_ids = [],school)
    @results = TestDataSetFile.where(state: school.state , data_set_id: data_set_ids)
                              .where('type like ?', '%school%')
                              .where('school_type like ?', "%#{school.type}%")
    @results.pluck(:data_set_id)
  end
end


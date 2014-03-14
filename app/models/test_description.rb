class TestDescription < ActiveRecord::Base
  self.table_name = 'test_description'
  db_magic :connection => :gs_schooldb
  attr_accessible :data_type_id, :description, :scale, :source, :state, :subgroup_description

  def self.by_data_type_ids(data_type_ids, state)
    begin
      TestDescription.where(data_type_id: data_type_ids, state: state).group_by(&:data_type_id)
    rescue => error
      Rails.logger.debug "Could not locate TestDescription for ids #{data_type_ids}"
    end
  end
end

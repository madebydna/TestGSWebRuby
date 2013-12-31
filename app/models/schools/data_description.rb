class DataDescription < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'data_description'
  attr_accessible :data_key, :state, :target, :value

  def self.fetch_descriptions(data_keys = [])
    DataDescription.where(data_key: data_keys)
  end

  def self.data_description_keys
    ['mi_state_accountability_summary','mi_esd_summary','what_is_gs_rating_summary']
  end
end

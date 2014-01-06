class DataDescription < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'data_description'
  attr_accessible :data_key, :state, :target, :value

  def self.fetch_descriptions(data_keys = [])
    DataDescription.where(data_key: data_keys)
  end

  def self.lookup_table
    Rails.cache.fetch('data_description/all_key_values', expires_in: 1.hour) do
      all.each_with_object({}) { |description, hash| hash[description["data_key"]] = description["value"] }
    end
  end

end

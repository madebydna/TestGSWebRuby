class CollectionConfig < ActiveRecord::Base
  self.table_name = 'hub_config'
  db_magic :connection => :gs_schooldb

  def self.key_value_map(collection_id)
    collection_id_to_key_value_map[collection_id] || {}
  end

  def self.collection_id_to_key_value_map
    Rails.cache.fetch('collection_id_to_key_value_map', expires_in: 5.minutes) do
      configs = {}
      order(:collection_id).each do |row|
        configs[row['collection_id'].to_i] ||= {}
        configs[row['collection_id']][row['quay']] = row['value']
      end
      configs
    end
  end
end
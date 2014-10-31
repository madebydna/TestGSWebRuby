class SchoolMetadata < ActiveRecord::Base
  include StateSharding
  self.table_name = 'school_metadata'

  belongs_to :school

  # Returns two dimensional array.
  # Each inner array's first element is collection ID and second element is school ID
  def self.collections_ids_to_school_ids
    Rails.cache.fetch('collection_ids_to_school_ids/all', expires_in: 5.minutes) do
      results = where(meta_key: 'collection_id')

      results.map do |metadata|
        [ metadata.meta_value.to_i, metadata.school_id ]
      end
    end
  end


  def self.school_ids_for_collection_ids(state,collection_id)
    results = self.on_db(state.to_sym).where(meta_key: 'collection_id', meta_value: collection_id.to_i)
    results.map(&:school_id)
  end
end

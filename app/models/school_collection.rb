class SchoolCollection < ActiveRecord::Base
  db_magic :connection => :gs_schooldb

  def self.school_collection_mapping
    @school_collection_mapping ||= (
      all.each_with_object(Hash.new { |h, k| h[k] = [] }) do |record, h|
        h[[record.state, record.school_id]] << record.collection_id
      end
    )
  end
end

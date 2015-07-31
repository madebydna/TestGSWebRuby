class SqlCollectionConfig < ActiveRecord::Base
  self.table_name = 'collection_configs'

  db_magic :connection => :gs_schooldb

  belongs_to :school_collection

end
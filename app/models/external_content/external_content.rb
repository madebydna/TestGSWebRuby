class ExternalContent < ActiveRecord::Base
  self.table_name = 'external_content'
  db_magic :connection => :gs_schooldb
  attr_accessible :content_key, :content
end
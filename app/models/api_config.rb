class ApiConfig < ActiveRecord::Base
  self.table_name = 'api_config'
  self.primary_key = 'account_id'
  db_magic :connection => :api_rw

  belongs_to :api_account, class_name: 'ApiAccount', foreign_key: :account_id

end
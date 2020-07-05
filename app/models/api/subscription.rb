module Api

  class Subscription < ActiveRecord::Base
    self.table_name = 'subscriptions'
    db_magic :connection => :api_rw
  end

end
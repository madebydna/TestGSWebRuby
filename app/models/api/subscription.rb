module Api

  class Subscription < ActiveRecord::Base
    self.table_name = 'subscriptions'
    db_magic :connection => :api_rw

    belongs_to :user
    belongs_to :plan
  end

  # plan selected
  # payment added
  # bizdev rejected
  # bizdev approved
  # payment charged successfully
  # payment failed

end
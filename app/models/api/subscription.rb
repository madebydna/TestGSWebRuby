module Api

  class Subscription < ActiveRecord::Base
    self.table_name = 'subscriptions'
    db_magic :connection => :api_rw

    belongs_to :user
    belongs_to :plan

    scope :pending_approval, -> { where status: 'pending_approval' }

    def pending_approval?
      status == 'pending_approval'
    end
  end

  # plan selected
  # payment_added
  # pending_approval
  # bizdev rejected
  # bizdev approved
  # payment charged successfully
  # payment failed

end
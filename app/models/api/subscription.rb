module Api

  class Subscription < ActiveRecord::Base
    self.table_name = 'subscriptions'
    db_magic :connection => :api_rw

    belongs_to :user, class_name: 'Api::User'
    belongs_to :plan, class_name: 'Api::Plan'

    scope :pending_approval, -> { where status: 'pending_approval' }

    def pending_approval?
      status == 'pending_approval'
    end
  end

  # Subscription Lifecycle
  # plan_selected -> Initial status after subscription is created via the plan selection page
  # payment_added -> Once user adds payment
  # pending_approval -> Once user clicks 'place order' on the confirmation page
  # bizdev_rejected -> bizdev reject the request via the api admin panel
  # bizdev_approved -> bizdev approve the request via the api admin panel
  # payment_succeeded -> once bizdev approve a request payment is attempted if it succeeds we update to this status
  # payment_failed -> once bizdev approve a request payment is attempted if it fails we update to this status

end
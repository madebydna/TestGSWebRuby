module Api
  # This class handles the approval logic for a subscription
  #   activates subscription in payment processor and charges the user
  # # on success:
  #     # update our local data store (Api::Subscription table set status to active)
  #     # send an email to user confirming start of subscription and subscription details
  #     # on failure:
  #     # send an email to user confirming failed approval
  #     # send an email to bizdev
  class AccountApprover

    attr_reader :subscription_id

    def initialize(subscription_id)
      @subscription_id = subscription_id
    end

    def approve
      update_status('bizdev_approved')
      create_subscription
      post_approval
    end

    def subscription
      @subscription ||= Api::Subscription.find(subscription_id)
    end

    def update_status(status)
      subscription.update(status: status)
    end

    def create_subscription
      @result = Api::SubscriptionCreator.new(subscription.user, subscription.plan.price_id)
    end

    def post_approval
      if @result
        update_status('')
      else

      end
    end

  end

end
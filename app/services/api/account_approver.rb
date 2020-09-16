module Api
  # This class handles the approval logic for a subscription
  class AccountApprover

    attr_reader :subscription_id

    def initialize(subscription_id)
      @subscription_id = subscription_id
    end

    def approve
      subscription.update(status: 'bizdev_approved')
      create_subscription
      post_approval
      subscription
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
        subscription.update(status: 'payment_succeeded', active: true)
        email_user
        email_biz_dev('success')
      else
        subscription.update(status: 'payment_failed', active: false)
        email_user
        email_biz_dev('fail')
      end
    end

    def email_user
      p "emailing user"
    end

    def email_biz_dev(status)
      if status == 'success'
        p "emailing biz dev success"
      else
        p "emailing biz dev fail"
      end

    end

  end

end
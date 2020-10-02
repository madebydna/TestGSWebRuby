module Api
  # This class handles the approval logic for a subscription
  class AccountApprover

    attr_reader :subscription_id

    def initialize(subscription_id)
      @subscription_id = subscription_id
    end

    def deactivate
      subscription.update(status: 'bizdev_deactivated')
      deactivate_stripe_subscription
      email_biz_dev
      email_user
      subscription
    end

    def subscription
      @subscription ||= Api::Subscription.find(subscription_id)
    end

    def deactivate_stripe_subscription
      Stripe::Subscription.delete(subscription.stripe_id)
    end

    def email_user
      p "emailing user"
    end

    def email_biz_dev
      if subscription.status == 'bizdev_deactivated'
        p "emailing biz dev success"
      else
        p "emailing biz dev fail"
      end
    end
  end

end
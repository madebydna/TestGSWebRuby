module Api
  # This class handles the approval logic for a subscription
  class AccountApprover

    attr_reader :subscription_id

    def initialize(subscription_id)
      @subscription_id = subscription_id
    end

    def approve
      subscription.update(status: 'bizdev_approved')
      create_stripe_subscription
      subscription
    end

    def subscription
      @subscription ||= Api::Subscription.find(subscription_id)
    end

    def stripe_subscription
      @stripe_subscription ||= Stripe::Subscription.create({ customer: subscription.user.stripe_customer_id,
                                                             items: [{ price: subscription.plan.stripe_price_id }] })
    end

    def create_stripe_subscription
      if stripe_subscription
        subscription.update(status: 'payment_succeeded', active: true)
      else
        subscription.update(status: 'payment_failed', active: false)
      end
      email_biz_dev
      email_user
    end

    def email_user
      p "emailing user"
    end

    def email_biz_dev
      if stripe_subscription
        p "emailing biz dev success"
      else
        p "emailing biz dev fail"
      end
    end
  end

end
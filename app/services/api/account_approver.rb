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
      email_biz_dev
      email_user
      subscription
    end

    def subscription
      @subscription ||= Api::Subscription.find(subscription_id)
    end

    def create_stripe_subscription
      stripe_sub = Stripe::Subscription.create({ customer: subscription.user.stripe_customer_id,
                                    items: [{ price: subscription.plan.stripe_price_id }] })
      subscription.update(status: 'payment_succeeded', active: true, stripe_id: stripe_sub.id)
      stripe_sub
    rescue Stripe::InvalidRequestError => e
      subscription.update(status: 'payment_failed', status_message: "#{e.message}", active: false)
      nil
    end

    def email_user
      p "emailing user"
    end

    def email_biz_dev
      if subscription.active?
        p "emailing biz dev success"
      else
        p "emailing biz dev fail"
      end
    end
  end

end
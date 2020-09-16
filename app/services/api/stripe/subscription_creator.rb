module Api
  # This class takes a user and price id and creates a subscription in stripe
  class SubscriptionCreator

    # activate subscription in stripe and charge user
    # on success:
    # update our local data store (Api::Subscription table set status to active)
    # send an email to user confirming start of subscription and subscription details
    # on failure:
    # send an email to user confirming failed approval
    # send an email to bizdev

    attr_reader :user, :price_id

    def initialize(user, price_id)
      @user = user
      @price_id = price_id
    end

    def call
      create_subscription
    end

    # https://stripe.com/docs/api/subscriptions
    def create_subscription
      Stripe::Subscription.create({ customer: user.stripe_customer_id,
                                    items: [{ price: price_id }] })
    end
  end
end
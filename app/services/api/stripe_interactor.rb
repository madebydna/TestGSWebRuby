module Api
  # This class encapsulates the logic for interacting with stripe
  class StripeInteractor

    # https://stripe.com/docs/api/customers/create
    def self.create_customer(user)
      customer = Stripe::Customer.create(email: user.email)
      user.update(stripe_customer_id: customer.id)
      customer.id
    end

    # https://stripe.com/docs/api/setup_intents
    def self.create_intent(stripe_customer_id)
      Stripe::SetupIntent.create({ customer: stripe_customer_id })
    end

    # https://stripe.com/docs/api/payment_methods
    def self.payments_list(user)
      Stripe::PaymentMethod.list({ customer: user.stripe_customer_id, type: 'card', })
    end

    # https://stripe.com/docs/api/subscriptions
    def self.create_subscription(user, price_id)
      Stripe::Subscription.create({ customer: user.stripe_customer_id,
                                    items:    [{ price: price_id }] })
    end

  end

end
module Api
  # This class encapsulates the logic for interacting with stripe
  class StripeInteractor

    # https://stripe.com/docs/api/setup_intents
    def self.create_intent(stripe_customer_id)
      Stripe::SetupIntent.create({ customer: stripe_customer_id })
    end

    # https://stripe.com/docs/api/payment_methods
    def self.payments_list(user)
      Stripe::PaymentMethod.list({ customer: user.stripe_customer_id, type: 'card', })
    end

  end

end
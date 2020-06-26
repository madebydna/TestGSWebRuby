module Api
  class StripeCustomerCreator

    def create(user)
      Stripe.api_key = 'sk_test_51GsZt5Ka3u1U9cuSErNUT3gNsZASMUTvDJX2mUiOViOOGtVdp1YA5IPy3spfa1M2GHx7JAddbV9uFc63QchuySKZ00hrceBLV1'

      customer = Stripe::Customer.create(
        email: user.email
      )

      user.update(stripe_customer_id: customer.id)

    end
  end
end
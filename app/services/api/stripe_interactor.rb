module Api
  class StripeInteractor

    def self.create_customer(user)
      customer = Stripe::Customer.create(email: user.email)
      user.update(stripe_customer_id: customer.id)
      customer.id
    end

    def self.payments_list(user)
      Stripe::PaymentMethod.list({ customer: user.stripe_customer_id, type: 'card', })
    end
  end

end
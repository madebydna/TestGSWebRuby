module Api
  # This class creates a customer in our payments processor and links it to our local user
  class StripeCustomerCreator

    attr_reader :stripe_customer_id
    attr_accessor :user

    def initialize(user)
      @user = user
    end

    def call
      create_stripe_user
      update_user
      stripe_customer_id
    end

    # https://stripe.com/docs/api/customers/create
    def create_stripe_user
      @stripe_customer_id = Stripe::Customer.create(email: user.email).id
    end

    private

    def update_user
      user.update(stripe_customer_id: stripe_customer_id)
      user
    end

  end

end
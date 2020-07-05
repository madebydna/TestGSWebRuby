module Api
  # This is a service object to create an api user and handle payment processing
  class UserCreator

    attr_reader :user, :plan_id

    def initialize(user, plan_id)
      @user = user
      @plan_id = plan_id
    end

    def create
      return unless user.save
      create_stripe_user
      create_intent
      create_subscription
      notify_user
      notify_admin
    end

    def create_stripe_user
      @stripe_customer_id = Api::StripeInteractor.create_customer(user)
    end

    def create_intent
      @intent = Api::StripeInteractor.create_intent(@stripe_customer_id)
    end

    def create_subscription
      Api::Subscription.create(user_id: user.id, status: 'awaiting_payment', plan_id: plan_id, active: 0)
    end

    def notify_user
      # ApiRequestReceivedEmail.deliver_to_api_key_requester(@user)
    end

    def notify_admin
      # ApiRequestToModerateEmail.deliver_to_admin(@user)
    end

  end

end
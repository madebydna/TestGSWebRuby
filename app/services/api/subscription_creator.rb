module Api
  # Handles the creation of an api subscription
  class SubscriptionCreator

    attr_reader :user, :plan_id

    def initialize(user, plan_id)
      @user    = user
      @plan_id = plan_id
    end

    def call
      create_subscription
    end

    def create_subscription
      Api::Subscription.create(user_id: user.id,
                               plan_id: plan_id,
                               status:  'plan_selected',
                               active:  0)
    end
  end

end
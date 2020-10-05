module Api
  # This class handles the rejection logic for a subscription
  class AccountRejector

    attr_reader :subscription_id

    def initialize(subscription_id)
      @subscription_id = subscription_id
    end

    def process
      subscription.update(status: 'bizdev_rejected')
      email_user
      subscription
    end

    def subscription
      @subscription ||= Api::Subscription.find(subscription_id)
    end

    def email_user
      p "emailing user - your request was rejected"
    end

  end

end
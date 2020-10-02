module Api
  # This class handles the rejection logic for a subscription
  class AccountRejector

    attr_reader :subscription_id

    def initialize(subscription_id)
      @subscription_id = subscription_id
    end

    def reject
      subscription.update(status: 'bizdev_rejected')
      subscription
    end

    def subscription
      @subscription ||= Api::Subscription.find(subscription_id)
    end

    def email_user
      p "emailing user"
    end

    def email_biz_dev
      if stripe_subscription
        p "emailing biz dev success"
      else
        p "emailing biz dev fail"
      end
    end
  end

end
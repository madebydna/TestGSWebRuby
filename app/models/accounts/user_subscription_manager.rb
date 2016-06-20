class UserSubscriptionManager

  def initialize(user)
    @user = user
  end

  def update(new_subscriptions)
    delete_subs = subscriptions_to_delete(new_subscriptions, get_subscriptions)
    add_subs = subscriptions_to_add(new_subscriptions, get_subscriptions)
    delete_subscriptions(delete_subs)
    save_subscriptions(add_subs)
  end

  def unsubscribe
    begin
      @user.subscriptions.destroy_all
    rescue
      GSLogger.error(:unsubscribe, nil, message: 'User unsubscribe failed', vars: {
          member_id: @user.id
      })
    end
  end

  private

  def save_subscriptions(subs_to_add)
    subs_to_add.each do |list|
      s = Subscription.new
      s.list = list
      s.member_id = @user.id
      unless s.save!
        GSLogger.error(:preferences, nil, message: 'User subscriptions failed to save', vars: {
            member_id: member_id,
            list: list
        })

      end
    end
  end

  def delete_subscriptions(subs_to_delete)
    begin
      subscriptions = @user.subscriptions.where(list: subs_to_delete)
      subscriptions.each { |s| SubscriptionHistory.archive_subscription(s) }
      subscriptions.destroy_all
    rescue
      GSLogger.error(:unsubscribe, nil, message: 'User delete subscriptions failed', vars: {
          member_id: @user.id
      })
    end
  end

  def get_subscriptions
    UserSubscriptions.new(@user).get
  end

  def subscriptions_to_add(a, b)
    a - b
  end

  def subscriptions_to_delete(a, b)
    b - a
  end
end

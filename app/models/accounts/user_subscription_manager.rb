class UserSubscriptionManager

  def initialize(user)
    @user = user
  end

  def update(new_subscriptions)
    delete_subscriptions(old_to_delete(new_subscriptions, get_subscriptions))
    save_subscriptions(new_to_add(new_subscriptions, get_subscriptions))
  end

  def unsubscribe
    @user.subscriptions.destroy_all
  end

  private

  def save_subscriptions(subs_to_add)
    subs_to_add.each do |list|
      s = Subscription.new
      s.list = list
      s.member_id = @user.id
      s.save
    end
  end

  def delete_subscriptions(subs_to_delete)
    @user.subscriptions.where(list: subs_to_delete).destroy_all
  end

  def get_subscriptions
    UserSubscriptions.new(@user).get
  end

  def new_to_add(a, b)
    a - b
  end

  def old_to_delete(a, b)
    b - a
  end
end

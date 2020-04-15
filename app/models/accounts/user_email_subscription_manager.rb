class UserEmailSubscriptionManager

  def initialize(user)
    @user = user
  end

  def update(new_subscriptions)
    del_subs = subscriptions_to_delete(new_subscriptions, get_subscriptions)
    add_subs = subscriptions_to_add(new_subscriptions, get_subscriptions)
    delete_subscriptions(del_subs)
    save_subscriptions(add_subs)
  end

  def unsubscribe
    begin
      delete_subscriptions(get_subscriptions)
      delete_grade_levels
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
      s.list = list[0]
      s.language = list[1]
      s.member_id = @user.id
      unless s.save!
        GSLogger.error(:preferences, nil, message: 'User subscriptions failed to save', vars: {
            member_id: member_id,
            list: list,
            language: language
        })

      end
    end
  end

  def delete_subscriptions(subs_to_delete)
    begin
      subscriptions = []
      subs_to_delete.each do |subscription|
        list = subscription[0]
        language = subscription[1]
        subscriptions += @user.subscriptions.where(list: list, language: language)
      end
      subscriptions.each { |s| SubscriptionHistory.archive_subscription(s) }
      subscriptions.each(&:destroy)
    rescue
      GSLogger.error(:unsubscribe, nil, message: 'User delete subscriptions failed', vars: {
          member_id: @user.id
      })
    end
  end

  def delete_grade_levels
    UserEmailGradeManager.new(@user).delete_grades
  end

  def get_subscriptions
    UserSubscriptions.new(@user).get.map { |r| [r[:list], r[:language]] }
  end

  def subscriptions_to_add(desired_subscriptions, current_subscriptions)
    desired_subscriptions - current_subscriptions
  end

  def subscriptions_to_delete(desired_subscriptions, current_subscriptions)
    current_subscriptions - desired_subscriptions
  end
end

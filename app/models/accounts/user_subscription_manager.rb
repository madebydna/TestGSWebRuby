class UserSubscriptionManager

  def initialize(user)
    @user = user
  end

  def update(new_subscriptions)
    # require 'pry'
    # binding.pry
    delete_subs_en = subscriptions_to_delete(new_subscriptions['en'], get_subscriptions['en'])
    delete_subs_es = subscriptions_to_delete(new_subscriptions['es'], get_subscriptions['es'])
    delete_subscriptions(delete_subs_en, 'en')
    delete_subscriptions(delete_subs_es, 'es')
    add_subs_en = subscriptions_to_add(new_subscriptions['en'], get_subscriptions['en'])
    add_subs_es = subscriptions_to_add(new_subscriptions['es'], get_subscriptions['es'])
    save_subscriptions(add_subs_en, 'en')
    save_subscriptions(add_subs_es, 'es')
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

  def save_subscriptions(subs_to_add, language)
    subs_to_add.each do |list|
      s = Subscription.new
      s.list = list
      s.member_id = @user.id
      s.language = language
      unless s.save!
        GSLogger.error(:preferences, nil, message: 'User subscriptions failed to save', vars: {
            member_id: member_id,
            list: list,
            language: language
        })

      end
    end
  end

  def delete_subscriptions(subs_to_delete, language)
    # TODO: FIX THIS
    begin
      subscriptions = @user.subscriptions_matching_lists(subs_to_delete, language)
      subscriptions.each { |s| SubscriptionHistory.archive_subscription(s) }
      subscriptions.destroy_all
    rescue
      GSLogger.error(:unsubscribe, nil, message: 'User delete subscriptions failed', vars: {
          member_id: @user.id
      })
    end
  end

  def delete_grade_levels
    UserGradeManager.new(@user).delete_grades
  end

  def get_subscriptions
    # UserSubscriptions.new(@user).get.map(&:to_s)
    subs = UserSubscriptions.new(@user).get
    {
      'en' => subs.select { |sub| sub[:language] == 'en' }.map(&:list),
      'es' => subs.select { |sub| sub[:language] == 'es' }.map(&:list)
    }
  end

  def subscriptions_to_add(desired_subscriptions, current_subscriptions)
    desired_subscriptions - current_subscriptions
  end

  def subscriptions_to_delete(desired_subscriptions, current_subscriptions)
    current_subscriptions - desired_subscriptions
  end
end

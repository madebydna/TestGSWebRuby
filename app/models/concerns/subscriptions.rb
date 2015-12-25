module Subscriptions
  def self.included(base)
    base.class_eval do
      has_many :subscriptions, foreign_key: 'member_id'
    end
  end

  def add_subscription!(*args)
    subscription = new_subscription *args
    subscription.save!
  end

  def safely_add_subscription!(list, school = nil)
    unless has_subscription?(list, school)
      subscription = new_subscription(list, school)
      subscription.save!
    end
  end

  def new_subscription(list, school = nil)
    now = Time.now

    subscription_product = Subscription.subscription_product list

    raise "Subscription #{list} not valid" if subscription_product.nil?

    state = school.present? ? school.state : 'CA'
    school_id = school.present? ? school.id : 0
    expires = subscription_product.duration.present? ? now + subscription_product.duration : nil

    subscriptions.build(
      list: subscription_product.name,
      state: state,
      school_id: school_id,
      updated: now.to_s,
      expires: expires
    )
  end

  def has_subscription?(list, school = nil)
    school_id = school.try(:id) || 0
    school_state = school.try(:state) || 'CA'
    if list == 'greatnews'
      subscriptions.any? do |subscription|
        subscription.list == list
      end
    else
      subscriptions.any? do |subscription |
        subscription.list == list && subscription.school_id == school_id && subscription.state == school_state && (subscription.expires.nil? || Time.parse(subscription.expires.to_s).future?)
      end
    end
  end

  def has_signedup?(list)
    subscriptions.any? do |subscription|
      subscription.list == list
    end
  end

  def subscription_id(list)
    subscriptions.any? do |subscription|
      if subscription.list == list
        return subscription.id
      end
    end
  end

end
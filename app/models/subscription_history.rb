class SubscriptionHistory < ActiveRecord::Base
  self.table_name = 'list_active_history'

  db_magic :connection => :gs_schooldb

  belongs_to :user, foreign_key: 'member_id'

  def self.from_subscription(subscription)
    subscription_history = SubscriptionHistory.new
    subscription_history.member_id = subscription.member_id
    subscription_history.list = subscription.list
    subscription_history.state = subscription.state
    subscription_history.school_id = subscription.school_id
    subscription_history.expires = subscription.expires
    subscription_history.list_active_id = subscription.id
    subscription_history.list_active_updated = subscription.updated
    subscription_history
  end

  def self.archive_subscription(subscription)
    subscription_history = from_subscription(subscription)
    subscription_history.save
  end

end

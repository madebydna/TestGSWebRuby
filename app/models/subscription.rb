class Subscription < ActiveRecord::Base
  self.table_name = 'list_active'

  db_magic :connection => :gs_schooldb

  belongs_to :user, foreign_key: 'member_id'

  class SubscriptionProduct < Struct.new(:name, :long_name, :duration, :isNewsletter)
  end

  SUBSCRIPTIONS = {
    mystat: SubscriptionProduct.new('mystat', 'My School Stats', nil, true),
  }

  def self.subscription_product(list)
    SUBSCRIPTIONS[list.to_sym]
  end

end
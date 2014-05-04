class Subscription < ActiveRecord::Base
  self.table_name = 'list_active'

  db_magic :connection => :gs_schooldb

  belongs_to :user, foreign_key: 'member_id'

  SubscriptionProduct = Struct.new(:name, :long_name, :duration, :isNewsletter)

  SUBSCRIPTIONS = {
    mystat: SubscriptionProduct.new('mystat', 'My School Stats', nil, true),
    mystat_private: SubscriptionProduct.new('mystat_private', 'My School Stats for private schools', nil, true),
    greatnews: SubscriptionProduct.new('greatnews', 'Great News', nil, true)
  }

  def self.subscription_product(list)
    SUBSCRIPTIONS[list.to_sym]
  end

end
class SubscriptionProductUser < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'subscription_product_users'
  belongs_to :user, foreign_key: 'user_id'


  attr_accessible :id,:user_id, :subscription_product_id,:config,:active,:created, :updated

  def self.for_user(user_id)
    SubscriptionProductUser.where(user_id: user_id)
  end

end

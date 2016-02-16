class SubscriptionProduct < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'subscription_products'
  attr_accessible :id,:name, :description, :created, :updated

  def self.for_product(name)
    SubscriptionProduct.where(name: name)
  end

end

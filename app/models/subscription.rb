class Subscription < ActiveRecord::Base
  self.table_name = 'list_active'

  db_magic :connection => :gs_schooldb

  belongs_to :user, foreign_key: 'member_id'

  SubscriptionProduct = Struct.new(:name, :long_name, :description, :duration, :isNewsletter)

  SUBSCRIPTIONS = {
    mystat: SubscriptionProduct.new('mystat', 'My School Stats',
                                    "Track your child's school stats - from test scores to teacher quality.", nil, true),
    mystat_unverified: SubscriptionProduct.new('mystat_unverified', 'My School Stats',
                                            "Track your child's school stats - from test scores to teacher quality.", nil, true),
    mystat_private: SubscriptionProduct.new('mystat_private', 'My School Stats',
                                            "Track your child's school stats - from test scores to teacher quality.", nil, true),
    greatnews: SubscriptionProduct.new('greatnews', 'Weekly newsletter',
                                       "The tips and tools you need to make smart choices about your child's education.", nil, true),
    sponsor: SubscriptionProduct.new('sponsor', 'Partner offers',
                                     'Receive valuable offers and information from GreatSchools partners.', nil, true),
    osp_partner_promos: SubscriptionProduct.new('osp_partner_promos', 'Weekly newsletter',
                                       'Relevant, occasional offers and special promotions from carefully chosen partners.', nil, false)
  }

  def self.subscription_product(list)
    SUBSCRIPTIONS[list.to_sym]
  end

  def self.have_available?(list)
    (list.is_a?(String) || list.is_a?(Symbol))? SUBSCRIPTIONS.include?(list.to_sym) : nil
  end

  def self.is_grouped?(list)
    if list=='mystat' || list=='mystat_private' || list=='mystat_unverified'
      true
    else
      false
    end
  end

end
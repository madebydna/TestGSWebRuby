class Subscription < ActiveRecord::Base
  include BehaviorForModelsWithSchoolAssociation
  self.table_name = 'list_active'

  db_magic :connection => :gs_schooldb

  belongs_to :user, foreign_key: 'member_id'
  alias_attribute :school_state, :state

  SubscriptionProduct = Struct.new(:name, :long_name, :description, :duration, :isNewsletter)

  SUBSCRIPTIONS = {
      mystat: SubscriptionProduct.new('mystat', 'My School Stats',
                                    "Track your child's school stats - from test scores to teacher quality.", nil, true),
      mystat_unverified: SubscriptionProduct.new('mystat_unverified', 'My School Stats - email unverified',
                                            "Track your child's school stats - from test scores to teacher quality.", nil, true),
      mystat_private: SubscriptionProduct.new('mystat_private', 'My School Stats - private schools',
                                            "Track your child's school stats - from test scores to teacher quality.", nil, true),
      greatnews: SubscriptionProduct.new('greatnews', 'Weekly newsletter',
                                       "The tips and tools you need to make smart choices about your child's education.", nil, true),
      greatkidsnews: SubscriptionProduct.new('greatkidsnews', 'Grade-by-grade newsletter',
                                       'Weekly essentials about your child\'s grade.', nil, true),
      sponsor: SubscriptionProduct.new('sponsor', 'Partner offers',
                                     'Receive valuable offers and information from GreatSchools partners.', nil, true),
      teacher_list: SubscriptionProduct.new('teacher_list', 'Teacher newsletter',
                                            'Sign up for resources and insights for teachers and school leaders.', nil, true),
      osp_partner_promos: SubscriptionProduct.new('osp_partner_promos', 'Partner offers for school officials',
                                       'Relevant, occasional offers and special promotions from carefully chosen partners.', nil, false),
      osp: SubscriptionProduct.new('osp', 'School official alerts',
                                                'Receive tips and updates about new features that help you make the best use of your GreatSchools school profile.', nil, false)
  }

  def name
    Subscription.subscription_product(list)&.name
  end

  def long_name
    Subscription.subscription_product(list)&.long_name
  end

  def description
    Subscription.subscription_product(list)&.description
  end

  def self.subscription_product(list)
    SUBSCRIPTIONS[list.to_sym]
  end

  def self.is_invalid?(list)
    !self.have_available?(list)
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

  def self.mss_subscribers_for_school(school)
    User.where(id: Subscription.where(state: school.state, school_id: school.id, list: 'mystat')
                       .pluck(:member_id).uniq)
  end
end

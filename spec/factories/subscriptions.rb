FactoryGirl.define do
  Subscription.switch_connection_to(:gs_schooldb)

  factory :subscription, class: Subscription do
        list :list
        state :state
        school_id :school_id
        updated Time.new
        expires :expires
  end
end
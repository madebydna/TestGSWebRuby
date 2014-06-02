FactoryGirl.define do
  Subscription.switch_connection_to(:gs_schooldb)

  factory :subscription, class: Subscription do
        list :greatnews
        state :CA
        school_id 0
        updated Time.now
        expires (Time.now + 1.day)
  end
end
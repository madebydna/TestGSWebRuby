FactoryGirl.define do

  factory :expired_banned_ip, class: BannedIp do
    updated BannedIp::EXPIRED_TIME.ago - 1.day
  end

  factory :banned_ip, class: BannedIp do
    updated Time.now
  end


end
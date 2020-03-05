FactoryBot.define do
  factory :subject, class: Omni::Subject do
    sequence(:name) { |n| "Subject #{n}" }
  end
end
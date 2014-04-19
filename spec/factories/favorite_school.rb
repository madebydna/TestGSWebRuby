FactoryGirl.define do
  factory :favorite_school do
    sequence(:id) { |id| id }
    school_id 1
    state 'CA'
  end
end
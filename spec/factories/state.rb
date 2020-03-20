FactoryBot.define do
  factory :state, class: Omni::State do
    state { 'California' }
    abbreviation { 'CA' }
  end
end
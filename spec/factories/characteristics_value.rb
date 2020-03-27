FactoryBot.define do
  factory :school_metrics_value, class: SchoolProfiles::CollegeReadinessComponent::CharacteristicsValue do
    subject { 'All subjects' }
    breakdown { 'All students' }
    year { 2018 }
    school_value { 123 }
    skip_create
    initialize_with do
      SchoolProfiles::CollegeReadinessComponent::CharacteristicsValue.from_hash(attributes)
    end
  end
end
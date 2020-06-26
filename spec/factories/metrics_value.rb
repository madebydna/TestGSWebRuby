FactoryBot.define do
  factory :school_metrics_value, class: MetricsCaching::Value do
    subject { 'Composite Subject' }
    breakdown { 'All students' }
    year { 2018 }
    school_value { 123 }
    skip_create
    initialize_with do
      MetricsCaching::Value.from_hash(attributes)
    end
  end

  factory :state_metrics_value, class: MetricsCaching::Value do
    subject { 'Composite Subject' }
    breakdown { 'All students' }
    year { 2018 }
    state_value { 123 }
    skip_create
    initialize_with do
      MetricsCaching::Value.from_hash(attributes)
    end
  end
end
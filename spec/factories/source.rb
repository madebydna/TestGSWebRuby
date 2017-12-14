FactoryGirl.define do
  factory :source, class: Gsdata::Source do
    sequence :id do |n|
      n
    end
    date_valid Time.now
    source_name 'Foo'
    notes 'Foo bar baz'
  end
end

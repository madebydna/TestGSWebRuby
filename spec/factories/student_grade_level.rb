FactoryGirl.define do
  factory :student_grade_level do
    sequence :id do |n|
      n
    end
    grade 'KG'
  end
end

FactoryBot.define do
  factory :main_staff_hash, class: Hash do
    district_value { 96.83 }
    grade { "All" }
    source_date_valid { "20160101 00:00:00" }
    source_name { "Civil Rights Data Collection" }
    state_value { 90.256 }

    initialize_with { attributes }
  end

  factory :other_staff_hash, class: Hash do
    district_value { 12.5 }
    grade { "All" }
    source_date_valid { "20160101 00:00:00" }
    source_name { "Civil Rights Data Collection" }
    state_value { 7.2569 }

    factory :full_time_other_staff do
      breakdowns { "full-time" }
    end

    factory :part_time_other_staff do
      breakdowns { "part-time" }
    end

    factory :no_other_staff do
     breakdowns { "no staff" }
    end
    
    initialize_with { attributes }
  end

  factory :teacher_staff_cache, class: Hash do
    defaults = {
      "Percentage of full time teachers who are certified" => [ FactoryBot.build(:main_staff_hash) ],
      "Percentage of teachers with less than three years experience" => [ FactoryBot.build(:main_staff_hash) ],
      "Ratio of students to full time counselors" => [ FactoryBot.build(:main_staff_hash) ],
      "Percent of Nurse Staff" => [ 
        FactoryBot.build(:full_time_other_staff), 
        FactoryBot.build(:part_time_other_staff), 
        FactoryBot.build(:no_other_staff)
      ]
    } 
    initialize_with { defaults.merge(attributes) } 
  end


end
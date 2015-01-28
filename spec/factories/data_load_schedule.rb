FactoryGirl.define do

  factory :data_load, class: Admin::DataLoadSchedule do
    sequence(:id) { |n| n }
    state 'ca'
    description 'A California Data Load'
    load_type 'Test'
    year_on_site 2013
    year_to_load 2014
    released '2013-04-04'
    acquired '2013-04-04'
    live_by '2013-04-04'

    factory :completed_data_load, class: Admin::DataLoadSchedule do
      complete 1
    end
    factory :incomplete_data_load, class: Admin::DataLoadSchedule do
      complete 1
    end
  end

end
FactoryBot.define do
  factory :district_record, aliases: [:alameda_city_unified_district_record] do
    # Workaround b/c FactoryBot thinks state and state_id are connected
    # and denote AR associations
    transient do
      state_id { "0161119" }
      state { "ca" }
    end
  
    after(:build) do |item, evaluator|
      item.state_id = evaluator.state_id
      item.state = evaluator.state
    end

    district_id 1
    city "Alameda"
    county "Alameda"
    FIPScounty "06001"
    fax "(510) 522-6926"
    home_page_url "http://www.alameda.k12.ca.us"
    lat "MyString"
    lon "MyString"
    name "Alameda City Unified"
    nces_code "0601770"
    num_schools "22"
    phone "(510) 337-7000"
    street "2200 Central Ave"
    zipcode "94501"
    level_code "e,m,h"
    level "KG,1,2,3,4,5,6,7,8,9,10,11,12"
    mail_street "2200 Central Ave."
    mail_city "Alameda"
    mail_zipcode "94501"
    zipcentroid 1
    type_detail 0
    created "2013-11-14 18:34:53"
    modified "2013-11-14 18:34:53"
    street_line_2 nil
    charter_only 0

    factory :oakland_unified_district_record do
      district_id 14
      city "Oakland"
      name "Oakland Unified School District"
    end
  
    factory :shelby_school_district_record do
      district_id 100
      city "Columbiana"
      name "Shelby County School District"
      state "al"
    end

    factory :stockton_unified_school_district do
      district_id 759
      city 'Stockton'
      name 'Stockton Unified School District'
    end
  end
end

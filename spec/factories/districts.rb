# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :district do
    state_id 1
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
    state "CA"
    level_code "e,m,h"
    level "KG,1,2,3,4,5,6,7,8,9,10,11,12"
    mail_street "2200 Central Ave."
    mail_city "Alameda"
    mail_zipcode "94501"
    zipcentroid 1
    type_detail 0
    active 1
    created "2013-11-14 18:34:53"
    modified "2013-11-14 18:34:53"
    modifiedBy "MyString"
    street_line_2 nil
    manual_edit_by "MyString"
    manual_edit_date "2013-11-14 18:34:53"
    notes "MyString"
    charter_only 0
  end
end

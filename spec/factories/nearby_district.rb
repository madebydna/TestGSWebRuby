FactoryGirl.define do

  factory :nearby_district, class: NearbyDistrict do
    district_id 1
    neighbor_id 2
    district_state 'CA'
    neighbor_state 'CA'
    distance 5
  end

end
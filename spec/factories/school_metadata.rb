FactoryGirl.define do
  factory :school_metadata do
    meta_key 'collection_id'
    meta_value '1'
  end

  factory :overall_rating_school_metadata, class: SchoolMetadata do
    meta_key 'overallRating'
    meta_value '9'
  end

  factory :facebook_school_metadata, class: SchoolMetadata do
    meta_key 'facebook_url'
    meta_value 'http://www.facebook.com/test'
  end
end

FactoryGirl.define do

  factory :solr_response_header, class:Hash do
    status 0
    QTime 1
    params {}

    initialize_with { attributes.stringify_keys }
  end

end

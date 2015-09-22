FactoryGirl.define do
  factory :homepage_features_external_content, class: ExternalContent do
    sequence(:id) { |n| n }
    content_key 'homepage_features'
    content do
      {
        'status' => 'ok',
        'first_feature' => {
          'heading' => 'Explore our new parenting site, GreatKids!',
          'posts' => [
            {
              'id' => 16418
            }
          ]
        }
      }.to_json
    end
  end


end
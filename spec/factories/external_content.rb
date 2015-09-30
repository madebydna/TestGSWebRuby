FactoryGirl.define do
  factory :homepage_features_external_content, class: ExternalContent do
    sequence(:id) { |n| n }
    content_key 'homepage_features'
    content do
      {
        'status' => 'ok',
        'en' => {
        'first_feature' => {
          'heading' => 'Set your child up for success!',
          'posts' => [{
            "id" => 18185,
            "type" => "page",
            "url" => "http=>//dev-wp.greatschools.org/gk/sbac-more-about-this-guide/",
            "title" => "SBAC more about this guide",
            "excerpt" => "Make the new Smarter Balanced state test work for your child.",
            "thumbnail" => "http=>//dev-wp.greatschools.org/gk/wp-content/uploads/2015/09/test-embed-thumbnail-creation-un-360x180.jpg",
            "custom_fields" => {
              "wpcf-promo" => [
                "Let us help you understand what these state test results mean, and it will help you to uncover your child's strengths and struggles."
              ]
            },
            "thumbnail_size" => "large-tile",
            "thumbnail_images" => {
              "large-tile" => {
                "url" => "http=>//dev-wp.greatschools.org/gk/wp-content/uploads/2015/09/test-embed-thumbnail-creation-un-360x180.jpg",
                "width" => 360,
                "height" => 180
              }
            }
          }]
        }
        },
        'es' => {
            'first_feature' => {
                'heading' => 'Establezca su hijo para el exito!',
                'posts' => []
            }
        }
      }.to_json
    end
  end
end
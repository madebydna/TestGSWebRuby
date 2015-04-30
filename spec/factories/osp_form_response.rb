FactoryGirl.define do
  factory :osp_form_response do
    sequence :id do |n|
      n
    end
    esp_membership_id 1
    response ({
      "boys_sports" => [
        {
          "entity_state" => "ca",
          "entity_id" => 1, #school_id
          "value" => "soccer",
          "member_id" => 1,
          "created" => Time.now,
          "esp_source" => "osp"
        },
        {
          "entity_state" => "ca",
          "entity_id" => 1, #school_id
          "value" => "basketball",
          "member_id" => 1,
          "created" => Time.now,
          "esp_source" => "osp"
        }
      ]
    }).to_json
    osp_question_id 1
    updated Time.now

    factory :osp_form_response_with_boys_sports
    factory :osp_form_response_with_different_boys_sports do
      response ({
        "boys_sports" => [
          {
            "entity_state" => "ca",
            "entity_id" => 1, #school_id
            "value" => "tennis",
            "member_id" => 1,
            "created" => Time.now,
            "esp_source" => "osp"
          },
          {
            "entity_state" => "ca",
            "entity_id" => 1, #school_id
            "value" => "badminton",
            "member_id" => 1,
            "created" => Time.now,
            "esp_source" => "osp"
          }
        ]
      }).to_json
    end

    factory :osp_form_response_that_is_a_day_old do
      response ({
        "boys_sports" => [
          {
            "entity_state" => "ca",
            "entity_id" => 1, #school_id
            "value" => "tennis",
            "member_id" => 1,
            "created" => Time.now - 1.day,
            "esp_source" => "osp"
          },
          {
            "entity_state" => "ca",
            "entity_id" => 1, #school_id
            "value" => "badminton",
            "member_id" => 1,
            "created" => Time.now - 1.day,
            "esp_source" => "osp"
            }
        ]
      }).to_json
    end

    factory :osp_form_response_that_is_a_day_in_the_future do
      response ({
        "boys_sports" => [
          {
            "entity_state" => "ca",
            "entity_id" => 1, #school_id
            "value" => "tennis",
            "member_id" => 1,
            "created" => Time.now + 1.day,
            "esp_source" => "osp"
          },
          {
            "entity_state" => "ca",
            "entity_id" => 1, #school_id
            "value" => "badminton",
            "member_id" => 1,
            "created" => Time.now + 1.day,
            "esp_source" => "osp"
            }
          ]
      }).to_json
    end

    factory :osp_form_response_with_transportation do
      response ({
        "transportation" => [
          {
            "entity_state" => "ca",
            "entity_id" => 1, #school_id
            "value" => "public_transit",
            "member_id" => 1,
            "created" => Time.now,
            "esp_source" => "osp"
          },
        ]
      }).to_json
    end

    trait :with_esp_member do
      ignore do
        school_id 1
        state 'ca'
        member_id 1
      end
      after(:create) do |osp_form_responses, evaluator|
        FactoryGirl.create(:esp_membership,
          id: osp_form_responses.esp_membership_id,
          school_id: evaluator.school_id,
          state: evaluator.state,
          member_id: evaluator.member_id
        )
      end
    end
  end
end

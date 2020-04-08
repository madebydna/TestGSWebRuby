FactoryBot.define do
    sequence :id do |n|
      n
    end

    factory :school do
      transient do
        collection_id 1
        collection nil
      end

      id
      name 'Alameda High School'
      city 'Alameda'
      state 'CA'
      created { Time.now.to_s }
      lat 37.801239
      lon -122.258301

      factory :demo_school do
        name 'A demo school'
        city 'Alameda'
        state 'CA'
        level_code 'h'
        type 'public'
        active false
        notes 'GREATSCHOOLS_DEMO_SCHOOL_PROFILE'
      end

      factory :school_with_new_profile do
        name 'A demo school'
        city 'Alameda'
        state 'CA'
        level_code 'h'
        type 'public'
        active true
        new_profile_school 5
      end

      factory :inactive_school do
        name 'Inactive School'
        city 'Alameda'
        state 'CA'
        level_code 'h'
        type 'public'
        active false
      end

      factory :alameda_high_school do
        name 'Alameda High School'
        city 'Alameda'
        state 'CA'
        level_code 'h'
        type 'public'
      end

      factory :cristo_rey_new_york_high_school do
        name 'Cristo Rey New York High School'
        city 'New York'
        state 'NY'
        level_code 'h'
        type 'public'
      end

      factory :cesar_chavez_academy_denver do
        name 'Cesar Chavez Academy Denver'
        city 'Denver'
        state 'CO'
        level_code 'e,m'
        type 'charter'
      end

      factory :bay_farm_elementary_school do
        name 'Bay Farm Elementary School'
        city 'Alameda'
        state 'CA'
        level_code 'e'
        type 'public'
      end

      factory :the_friendship_preschool do
        name 'The Friendship Preschool'
        city 'Encinitas'
        state 'CA'
        level_code 'p'
        type 'private'
      end

      factory :emery_secondary do
        name 'Emery Secondary'
        city 'Emeryville'
        state 'CA'
        level_code 'm,h'
        type 'public'
      end

      factory :south_san_francisco_high_school do
        name 'South San Francisco High School'
        city 'San Francisco'
        state 'CA'
        level_code 'h'
        type 'public'
      end

      factory :washington_dc_ps_head_start do
        name 'Washington Dc Ps Head Start'
        city 'Washington'
        state 'DC'
        level_code 'p'
        type 'private'
      end

      factory :an_elementary_school do
        name 'Elementary School'
        city 'San Francisco'
        state 'CA'
        level_code 'e'
        type 'public'
      end

      factory :a_prek_elem_middle_high_school do
        name 'All Grade School'
        city 'San Francisco'
        state 'CA'
        level_code 'p,e,m,h'
        type 'private'
      end

      factory :a_high_school do
        name 'High School'
        city 'San Francisco'
        state 'CA'
        level_code 'h'
        type 'private'
      end

      factory :school_with_rating do
        transient do
          # Elements of this array should be in this format:
          # { data_type_id: 174, breakdown_id: 1, value_float: 10 },
          # { data_type_id: 174, breakdown_id: 8, value_float: 9  },
          # Note that value_float is a required field and that any
          # TestDataSet attributes can be used.
          ratings []
        end

        after(:create) do |school, evaluator|
          evaluator.ratings.each do |rating|
            data_set_attrs = {
              display_target: 'ratings'
            }.merge(rating.except(:value_float))
            data_set = TestDataSet
              .on_db(school.shard)
              .where(data_set_attrs)
              .first_or_initialize
            data_set.save!

            school_value_attrs = {
              active: 1,
              school_id: school.id,
              data_set_id: data_set.id,
              value_float: rating[:value_float]
            }
            school_value = TestDataSchoolValue.on_db(school.shard).where(school_value_attrs).first_or_initialize
            school_value.save!
          end
        end
      end

      trait :with_district do
        transient do
          district_name ''
        end
        before(:create) do |school, evaluator|
          district = FactoryBot.create(
            :district,
            name: evaluator.district_name
          )
          school.district_id = district.id
        end
      end

      trait :with_gs_rating do
        transient do
          gs_rating 4 #default
        end

        after(:create) do |school, evaluator|
          FactoryBot.create(
            :school_metadata,
            school_id: school.id,
            meta_key: 'overallRating',
            meta_value: evaluator.gs_rating
          )
        end
      end

      trait :with_levels do
        level '9,10,11,12'
        level_code 'h'
      end

      factory :page_view_school do
        name 'A demo school'
        county 'Alameda County'
        city 'Alameda'
        state 'CA'
        level_code 'h'
        type 'public'
        active true
        notes 'GREATSCHOOLS_DEMO_SCHOOL_PROFILE'
        with_gs_rating
        with_district
      end
    end

    factory :school_with_params, class: School do
      id :id
      state :state
      city :city ? :city : 'alameda'
    end
end

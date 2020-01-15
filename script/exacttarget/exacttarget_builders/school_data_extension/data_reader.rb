# frozen_string_literal: true

module ExactTarget
  module SchoolDataExtension
    class DataReader
      # include Rails.application.routes.url_helpers
      # include UrlHelper
      include Feeds::FeedConstants
      include Feeds::FeedHelper
      BATCH_SIZE = 100000
      COLUMN_TITLES = '"id","school_type","level_code","state","name","street_address_1","street_address_2","city","zip_code","phone_number","district_id","district_name","district_city","district_state","city_id","district_city_id"'


      def initialize

        @states = {}
        # User.all.order_by(:id).find_in_batches(batch_size: 100000) do |users|
        #   users.each do |user|
        #     user.recalculate_statistics!
        #   end
        # end
        User.where("id <= ?", 200000).find_in_batches(batch_size: BATCH_SIZE).with_index do |users, index|
          batch_index = (index + 1)*BATCH_SIZE
          puts "Users #{users.count} #{batch_index}"
          puts "file name: members.#{batch_index}.txt"
          # write headers only on the first file created
          # update file name for next group - format members.3600000.txt
          users.each do |user|
            # user information from list_member
            user['id']
            user['email']
            # user['opted_in'] # need to find this - user['email_verified']
            user['first_name']
            user['email_verified'] # - possibly kill
            user['gender']
            user['updated'] # need to format
            user['time_added'] # need to format
            # user['hash_token'] # need to generate this?
            user['how']
            user['town']
            # user['state'] # no idea where this comes from - kill

            # need to query the lists they are signed up for and the grades - list_active and student tables
            user['great_news'] # greatnews - 1 or 0
            user['learning_disabilities'] # learning_dis - kill
            user['chooser_pack'] # not sure four kinds chooserpack_p chooserpack_e chooserpack_m chooserpack_h ???? - kill
            user['sponsor'] # sponsor - 1 or 0
            user['summer_brain_drain']  # summer3 summer7 summer8 ???? - kill
            user['summer_brain_drain_start_week'] # summer3 summer7 summer8 ???? - kill
            user['grade_by_grade']  # greatkidsnews - 1 or 0
            user['my_stats'] # any mystats - 1 or 0

            # list of schools - four times required # mystat - mystat_private ??
            user['school_id']
            user['school_state']
            user['school_name']
            user['school_city']
            user['school_level']

            #list of grade by grade they are signed up for
            # student has grade and member_id
            user['grade_pk']
            user['grade_kg']
            user['grade_1']
            user['grade_2']
            user['grade_3']
            user['grade_4']
            user['grade_5']
            user['grade_6']
            user['grade_7']
            user['grade_8']
            user['grade_9']
            user['grade_10']
            user['grade_11']
            user['grade_12']

            # need to determine if a user is osp user
            user['osp'] # this is a list type - 1 or 0

          end
        end

      end

      def select_school(state, id)
        school_array.find { |b| b[:state]==state && b[:id]==id }
      end

      def select_district(state, id)
        district_array.find { |b| b[:state]==state && b[:id]==id }
      end

      def select_city(state, name)
        city_array.find { |b| b[:state]==state && b[:name]==name }
      end

      # mappings from columns to school db value
      # "id" id
      # "school_type" type
      # "level_code" level_code
      # "state" state
      # "name" name
      # "street_address_1" street
      # "street_address_2" '' # remove this does not exist in db
      # "city" city
      # "zip_code" zipcode
      # "phone_number" phone
      # "district_id" district_id

      # create a district table for these values
      # "district_name"
      # "district_city"
      # "district_state"
      # "city_id"
      # "district_city_id"

      # possible add canonical_url
      # possibly add ratings and subratings

      def school_array
        @_school_array ||= begin
          @_school_array = []
          State.all.pluck('state').each do |state|
            @_school_array.concat(
              School.within_state(state).not_preschool_only.map do |school|
                {
                  id: school.id,
                  state: school.state,
                  name: school.name,
                  city: school.city,
                  level: school.level_code
                }
              end
            )
          end
        end
      end

      def city_array
        @_city_array ||= begin
          @_city_array = []
          State.all.pluck('state').each do |state|
            @_city_array.concat(
                City.all.active.map do |city|
                  {
                      id: city.id,
                      state: city.state,
                      name: city.name
                  }
                end
            )
          end
        end
      end

      def district_array
        @_district_array ||= begin
          @_district_array = []
          State.all.pluck('state').each do |state|
            @_district_array.concat(
                DistrictRecord.all.active.map do |district|
                  {
                      id: district.district_id,
                      state: district.state,
                      name: district.name,
                      city: district.city,
                      level: district.level_code
                  }
                end
            )
          end
        end
      end

      def default_url_options
        { trailing_slash: true, protocol: 'https', host: 'www.greatschools.org', port: nil }
      end

      def each_result(&block)
        results.each(&block)
      end

      def state_results
        {}.tap do |hash|
          hash['id'] = test_type_to_id
          hash['year'] = @state_data['year']
          hash['description'] = @state_data['description']
        end
      end

      def test_type_to_id
        @_test_type_to_id ||= begin
            @state.upcase + RATING_IDS[@rating_type].to_s.rjust(5, "0")
        end
      end

      def school_rating(school)
        @rating_type == 'Summary Rating' ?  school.overall_gs_rating : school.test_scores_rating
      end

      def results
        ratings_hashes
      end

      def school_ids
        @schools.map(&:id)
      end

      def ratings_hashes
        @_ratings_hashes ||= begin
          ratings_caches.map do |school|
            {
                'universal-id' => school_uid(school.id),
                'test-rating-id' => test_type_to_id,
                'rating' => school_rating(school),
                'url' => school_url(school)
            }
          end
        end
      end

      def ratings_caches
        @_ratings_caches ||= begin
          query = SchoolCacheQuery.new.include_cache_keys('ratings').include_schools(@state, school_ids)
          query_results = query.query_and_use_cache_keys
          school_cache_results = SchoolCacheResults.new('ratings', query_results)
          school_cache_results.decorate_schools(schools)
        end
      end

      private

      def school_uid(id)
        transpose_universal_id(@state, Struct.new(:id).new(id), ENTITY_TYPE_SCHOOL)
      end

      def state_uid
        transpose_universal_id(@state, nil, nil)
      end
    end
  end
end

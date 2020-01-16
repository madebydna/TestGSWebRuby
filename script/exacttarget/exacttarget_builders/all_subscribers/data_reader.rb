# frozen_string_literal: true

module ExactTarget
  module AllSubscribers
    class DataReader
      # include Rails.application.routes.url_helpers
      # include UrlHelper
      include Feeds::FeedConstants
      include Feeds::FeedHelper
      BATCH_SIZE = 100000
      COLUMN_TITLES = "member_id,Email Address,opted_in,first_name,email_verified,gender,updated,time_added,
            hash_token,how,city,state,GreatNews,Learning Disabilities,Chooser Pack,Sponsor,
            Summer Brain Drain,Summer Brain Drain Start Week,Grade by grade,MyStats,
            School 1 Id,School 1 State,School 1 Name,School 1 City, School 1 Level,
            School 2 Id,School 2 State,School 2 Name,School 2 City, School 2 Level,
            School 3 Id,School 3 State,School 3 Name,School 3 City, School 3 Level,
            School 4 Id,School 4 State,School 4 Name,School 4 City, School 4 Level,
            Grade PK,Grade KG,Grade 1,Grade 2,Grade 3,Grade 4,Grade 5,Grade 6,
            Grade 7,Grade 8,Grade 9,Grade 10,Grade 11,Grade 12,OSP"


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
            # UserVerificationToken
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
        @states.find { |b| b[:state]==state && b[:id]==id }
      end

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

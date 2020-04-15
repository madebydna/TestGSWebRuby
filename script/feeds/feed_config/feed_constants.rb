# frozen_string_literal: true

module Feeds
  module FeedConstants
      FEED_CACHE_KEYS = %w(feed_test_scores ratings)

      DIRECTORY_FEED_SCHOOL_CACHE_KEYS = %w(directory feed_metrics gsdata)

      DIRECTORY_FEED_DISTRICT_CACHE_KEYS = %w(district_directory feed_metrics gsdata)

      DIRECTORY_STATE_KEYS = %w(universal_id state_name state census_info)

      # attributes for directory feeds from model, cache, or method call. Does not include census info data values
      DIRECTORY_STATE_ATTRIBUTES = %w(universal_id state_name state)
      DIRECTORY_DISTRICT_ATTRIBUTES = %w(universal_id state_id nces_code name description street city state zip county FIPScounty level level_code lat lon phone fax web_site url)
      DIRECTORY_SCHOOL_ATTRIBUTES = %w(universal_id id state_id nces_code name description street city state zip county FIPScounty level level_code district_id lat lon phone fax web_site subtype type district_name universal_district_id url)

      WITH_NO_BREAKDOWN = 'with_no_breakdown'

      WITH_ALL_BREAKDOWN = 'wth_all_breakdown'

      FEED_NAME_MAPPING = {
          'test_scores' => 'local-gs-test-feed',
          'test_subgroup' => 'local-gs-test-subgroup-feed',
          'test_rating' => 'local-gs-test-rating-feed',
          'subrating' => 'local-gs-subrating-feed',
          'subrating_description' => 'local-gs-subrating-description-feed',
          'official_overall_rating_flat' => 'local-gs-official-overall-rating-result-feed-flat',
          'official_overall_rating_description' => 'local-gs-official-overall-rating-feed-flat',
          'official_overall_rating' => 'local-gs-official-overall-rating-feed',
          'old_test_gsdata' => 'local-gs-test-feed',
          'old_test_subgroup_gsdata' => 'local-gs-test-subgroup-feed',
          'new_test_gsdata' => 'local-gs-new-test-feed',
          'new_test_gsdata_csv' => 'local-gs-new-test-result-feed',
          'new_test_subgroup_gsdata' => 'local-gs-new-test-subgroup-feed',
          'official_overall' => 'local-gs-official-overall-rating-feed',
          'directory_feed' => 'local-greatschools-feed',
          'google_feed' => 'local-google-feed',
          'city' => 'local-greatschools-city-feed',
          'proficiency_band' => 'gs-proficiency-band',
          'parent_reviews' => 'local-gs-parent-review-feed',
          'parent_reviews_flat' => 'local-gs-parent-review-feed-flat',
          'parent_ratings_flat' => 'local-gs-parent-ratings-feed-flat',
          'directory_feed_flat' => 'local-greatschools-feed-flat',
          'directory_census_flat' => 'local-gs-census-feed-flat'
      }

      VALID_FEED_NAMES = %w(subrating old_test_gsdata old_test_subgroup_gsdata new_test_gsdata new_test_subgroup_gsdata subrating_description official_overall_rating official_overall_rating_description official_overall_rating_flat parent_reviews parent_reviews_flat parent_ratings_flat directory_feed directory_feed_flat directory_census_flat)

      VALID_FEED_FORMATS = %w(xml csv txt)

      RATINGS_ID_RATING_FEED_MAPPING = {
          'test_rating' => 164,
          'official_overall' => 174
      }

      DATA_TYPE_TEST_SCORE_FEED_MAPPING = {
          'test_scores' => WITH_NO_BREAKDOWN,
          'test_subgroup' => WITH_ALL_BREAKDOWN,
      }

      FEED_TO_SCHEMA_MAPPING = {
          'common_schema' => 'https://www.greatschools.org/feeds/greatschools-common.xsd',
          'test_scores' => 'https://www.greatschools.org/feeds/greatschools-test.xsd',
          'test_subgroup' => 'https://www.greatschools.org/feeds/greatschools-test-subgroup.xsd',
          'test_rating' => 'https://www.greatschools.org/feeds/greatschools-test-rating.xsd',
          'official_overall' => 'https://www.greatschools.org/feeds/gs-official-overall-rating.xsd',
          'directory_feed' => 'https://www.greatschools.org/feeds/local-greatschools.xsd',
          'google_feed' => 'https://www.gstatic.com/localfeed/local_feed.xsd',
          'city' => 'https://www.greatschools.org/feeds/greatschools-city2.xsd',
          'proficiency_band' => 'https://www.greatschools.org/feeds/gs-proficiency-band.xsd',
          'feed_test_scores_gsdata' => 'https://www.greatschools.org/feeds/gs-test.xsd',
          'feed_test_scores_subgroup_gsdata' => 'https://www.greatschools.org/feeds/gs-test-subgroups.xsd',
          'subrating' => 'https://www.greatschools.org/feeds/gs-subrating.xsd',
          'parent_reviews' => 'https://www.greatschools.org/feeds/local-gs-parent-review.xsd',
      }

      # possible remove this since we will be official off of generate_feed_files
      FEED_TO_ROOT_ELEMENT_MAPPING = {
          'test_scores' => 'gs-test-feed',
          'test_subgroup' => 'gs-test-subgroup-feed',
          'test_rating' => 'gs-test-rating-feed',
          'official_overall' => 'gs-official-overall-rating-feed',
          'directory_feed' => 'gs-local-feed',
          'google_feed' => 'listings',
          'city' => 'greatschools-city-feed',
          'proficiency_band' => 'proficiency-band-feed',
          'feed_test_scores_gsdata' => 'gs-test-feed',
          'feed_test_scores_subgroups_gsdata' => 'gs-test-subgroups-feed',
          'subrating' => 'gs-subrating-feed',
          'subrating_description' => 'gs-subrating-description-feed'
      }

      PROFICIENT_AND_ABOVE_BAND = 'proficient and above'

      ENTITY_TYPE_SCHOOL = 'school'

      ENTITY_TYPE_DISTRICT = 'district'

      ENTITY_TYPE_STATE = 'state'

      DEFAULT_BATCH_SIZE = 1

      # this is the required order for school and district content
      DIRECTORY_SCHOOL_KEY_ORDER = %w(universal_id id state_id nces_code name description street city state zipcode county FIPScounty level level_code district_id lat lon phone fax home_page_url subtype type district_name universal_district_id district_spending url census_info school_summary)
      DIRECTORY_DISTRICT_KEY_ORDER = %w(universal_id state_id nces_code name description street city state zipcode county FIPScounty level level_code lat lon phone fax home_page_url url census_info)

      # this is a white list of keys we are looking for
      DIRECTORY_SCHOOL_KEYS_REQUIRED = %w(id name description street city state county level level_code district_id lat lon subtype type web_site)
      DIRECTORY_DISTRICT_KEYS_REQUIRED = %w(name description street city state county level level_code web_site)

      #  REQUIRED - universal_id zipcode home_page_url url
      DIRECTORY_SCHOOL_KEYS_SPECIAL = %w(universal_id zipcode home_page_url url universal_district_id census_info level)
      DIRECTORY_DISTRICT_KEYS_SPECIAL = %w(universal_id zipcode home_page_url url census_info level)

      # this is a white list of keys we are looking for - executes a method to handle type of data
      CHARACTERISTICS_MAPPING = [
          # comes from gsdata now
          # {
          #     key: 'Student teacher ratio',
          #     method: 'student_teacher_ratio',
          #     google_key: 'Student teacher ratio'
          # },
          {
              key: 'Ratio of students to full time teachers',
              method: 'student_teacher_ratio',
              google_key: 'Ratio of students to full time teachers'
          },
          {
              key: 'Head official name',
              method: 'straight_text_value',
              data_type: 'head-official-name',
              google_key: 'Head Official Name'
          },
          {
              key: 'Head official email address',
              method: 'straight_text_value',
              data_type: 'head-official-email',
              google_key: 'Head Official Email'
          },
          {
              key: 'Enrollment',
              method: 'enrollment',
              google_key: 'Enrollment'
          },
          # {
          #     key: 'Membership',
          #     method: 'membership'
          # },
          # {
          #     key: 'Bilingual Education (y/n)',
          #     method: 'bilingual-education'
          # },
          # {
          #     key: 'Special Education (y/n)',
          #     method: 'special-education'
          # },
          # {
          #     key: 'Extended Care (y/n)',
          #     method: 'extended-care'
          # },
          # {
          #     key: 'Computers In Classroom (y/n)',
          #     method: 'computers-in-classroom'
          # },
          # {
          #     key: 'Low Age',
          #     method: 'low-age'
          # },
          # {
          #     key: 'High Age',
          #     method: 'high-age'
          # },
          {
              key: 'Students participating in free or reduced-price lunch program',
              method: 'free_or_reduced_lunch_program',
              google_key: 'Percent qualifying for free or reduced lunch'
          },
          {
              key: 'Average years of teacher experience',
              method: 'teacher_data',
              data_type: 'average teacher experience years',
              google_key: 'Average years of teacher experience'
          },
          {
              key: 'Average years of teaching in district',
              method: 'teacher_data',
              data_type: 'average years teaching in district',
              google_key: 'Average years of teaching in district'
          },
          {
              key: 'Percent classes taught by highly qualified teachers',
              method: 'teacher_data',
              data_type: 'percent classes taught by highly qualified teachers',
              google_key: 'Percent classes taught by highly qualified teachers'
          },
          {
              key: 'Percent classes taught by non-highly qualified teachers',
              method: 'teacher_data',
              data_type: 'percent classes taught by non highly qualified teachers',
              google_key: 'Percent classes taught by non-highly qualified teachers'
          },
          {
              key: 'Percentage of teachers in their first year',
              method: 'teacher_data',
              data_type: 'percent teachers in first year',
              google_key: 'Percentage of teachers in their first year'
          },
          {
              key: 'Teaching experience 0-3 years',
              method: 'teacher_data',
              data_type: 'percent teachers with 3 years or less experience',
              google_key: 'Teaching experience 0-3 years'
          },
          {
              key: 'at least 5 years teaching experience',
              method: 'teacher_data',
              data_type: 'percent teachers with at least 5 years experience',
              google_key: 'at least 5 years teaching experience'
          },
          {
              key: "Bachelor's degree",
              method: 'teacher_data',
              data_type: 'percent teachers with bachelors degree',
              google_key: "Bachelor's degree"
          },
          {
              key: "Doctorate's degree",
              method: 'teacher_data',
              data_type: 'percent teachers with doctorate degree',
              google_key: "Doctorate's degree"
          },
          {
              key: "Master's degree",
              method: 'teacher_data',
              data_type: 'percent teachers with masters degree',
              google_key: "Master's degree"
          },
          {
              key: "Master's degree or higher",
              method: 'teacher_data',
              data_type: 'percent teachers with masters or higher',
              google_key: "Master's degree or higher"
          },
          {
              key: 'Teachers with valid license',
              method: 'teacher_data',
              data_type: 'percent teachers with valid license',
              google_key: 'Teachers with valid license'
          },
          {
              key: 'Teachers with no valid license',
              method: 'teacher_data',
              data_type: 'percent teachers with no valid license',
              google_key: 'Teachers with no valid license'
          },
          {
              key: 'Other degree',
              method: 'teacher_data',
              data_type: 'percent teachers with other degree',
              google_key: 'Other degree'
          },
          {
              key: 'English learners',
              method: 'students_with_limited_english_proficiency',
              google_key: 'Percentage of students with limited english proficiency'
          },
          {
              key: 'Students who are economically disadvantaged',
              method: 'percent_economically_disadvantaged',
              google_key: 'Percentage of students who are economically disadvantaged'
          },
          # {
          #     key: 'Per Pupil Spending',
          #     method: 'per-pupil-spending'
          # },
          # {
          #     key: 'Total Per Pupil Spending',
          #     method: 'total-per-pupil-spending'
          # },
          # {
          #     key: 'Average Salary',
          #     method: 'average-salary'
          # },
          # {
          #     key: 'Graduation rate',
          #     method: 'graduation-rate'
          # },
          # {
          #     key: "Class size.  If grade is not specified, then it's a entity wide count",
          #     method: 'class-size'
          # },
          {
              key: 'Ratio of teacher salary to total number of teachers',
              method: 'average_teacher_salary',
              google_key: 'Average teacher salary'
          },
          {
              key: 'Percentage of full time teachers who are certified',
              method: 'percentage_teachers_certified',
              google_key: 'Percentage of full time teachers who are certified'
          },
          {
              key: 'Percentage of teachers with less than three years experience',
              method: 'teacher_experience',
              google_key: 'Percentage of teachers with 3 or more years experience'
          },
          {
              key: 'Ratio of students to full time counselors',
              method: 'student_counselor_ratio',
              google_key: 'Ratio of students to full time counselors'
          },
          {
              key: 'Female',
              method: 'female',
              google_key: 'Percentage of female students'
          },
          {
              key: 'Male',
              method: 'male',
              google_key: 'Percentage of male students'
          },
          {
              key: 'Ethnicity',
              method: 'ethnicity',
              google_key: 'Ethnicity'
          }
      ].freeze

      CENSUS_CACHE_ACCESSORS =[
        {
          key: 'Ratio of students to full time teachers',
          feed_name: 'student-teacher-ratio',
          attributes: [:universal_id, :value, :year],
          formatting: [:to_f, :round, 2]
        },
        {
          key: 'Head official name',
          feed_name: 'head-official-name',
          attributes: [:universal_id, :value, :year]
        },
        {
          key: 'Head official email address',
          feed_name: 'head-official-email',
          attributes: [:universal_id, :value, :year]
        },
        {
          key: 'Enrollment',
          feed_name: 'enrollment',
          attributes: [:universal_id, :value, :year],
          formatting: [:to_i]
        },
        {
          key: 'Students participating in free or reduced-price lunch program',
          feed_name: 'percent-free-and-reduced-price-lunch',
          attributes: [:universal_id, :value, :year],
          formatting: [:to_f, :round, 1]
        },
        {
          key: 'Average years of teacher experience',
          feed_name: 'teacher-data',
          attributes: [:universal_id, :value, :year, :data_type],
          formatting: [:to_f, :round, 1],
          data_type: 'average teacher experience years'
        },
        {
          key: 'Average years of teaching in district',
          feed_name: 'teacher-data',
          attributes: [:universal_id, :value, :year, :data_type],
          formatting: [:to_f, :round, 1],
          data_type: 'average years teaching in district',
        },
        {
          key: 'Percent classes taught by highly qualified teachers',
          feed_name: 'teacher-data',
          attributes: [:universal_id, :value, :year, :data_type],
          formatting: [:to_f, :round, 1],
          data_type: 'percent classes taught by highly qualified teachers',
        },
        {
          key: 'Percent classes taught by non-highly qualified teachers',
          feed_name: 'teacher-data',
          attributes: [:universal_id, :value, :year, :data_type],
          formatting: [:to_f, :round, 1],
          data_type: 'percent classes taught by non highly qualified teachers',
        },
        {
          key: 'Percentage of teachers in their first year',
          feed_name: 'teacher-data',
          attributes: [:universal_id, :value, :year, :data_type],
          formatting: [:to_f, :round, 1],
          data_type: 'percent teachers in first year',
        },
        {
          key: 'Teaching experience 0-3 years',
          feed_name: 'teacher-data',
          attributes: [:universal_id, :value, :year, :data_type],
          formatting: [:to_f, :round, 1],
          data_type: 'percent teachers with 3 years or less experience',
        },
        {
          key: 'at least 5 years teaching experience',
          feed_name: 'teacher-data',
          attributes: [:universal_id, :value, :year, :data_type],
          formatting: [:to_f, :round, 1],
          data_type: 'percent teachers with at least 5 years experience',
        },
        {
          key: "Bachelor's degree",
          feed_name: 'teacher-data',
          attributes: [:universal_id, :value, :year, :data_type],
          formatting: [:to_f, :round, 1],
          data_type: 'percent teachers with bachelors degree',
        },
        {
          key: "Doctorate's degree",
          feed_name: 'teacher-data',
          attributes: [:universal_id, :value, :year, :data_type],
          formatting: [:to_f, :round, 1],
          data_type: 'percent teachers with doctorate degree',
        },
        {
          key: "Master's degree",
          feed_name: 'teacher-data',
          attributes: [:universal_id, :value, :year, :data_type],
          formatting: [:to_f, :round, 1],
          data_type: 'percent teachers with masters degree',
        },
        {
          key: "Master's degree or higher",
          feed_name: 'teacher-data',
          attributes: [:universal_id, :value, :year, :data_type],
          formatting: [:to_f, :round, 1],
          data_type: 'percent teachers with masters or higher',
        },
        {
          key: 'Teachers with valid license',
          feed_name: 'teacher-data',
          attributes: [:universal_id, :value, :year, :data_type],
          formatting: [:to_f, :round, 1],
          data_type: 'percent teachers with valid license',
        },
        {
          key: 'Teachers with no valid license',
          feed_name: 'teacher-data',
          attributes: [:universal_id, :value, :year, :data_type],
          formatting: [:to_f, :round, 1],
          data_type: 'percent teachers with no valid license',
        },
        {
          key: 'Other degree',
          feed_name: 'teacher-data',
          attributes: [:universal_id, :value, :year, :data_type],
          formatting: [:to_f, :round, 1],
          data_type: 'percent teachers with other degree',
        },
        {
          key: 'English learners',
          feed_name: 'percent-students-with-limited-english-proficiency',
          attributes: [:universal_id, :value, :year],
          formatting: [:to_f, :round, 3]
        },
        {
          key: 'Students who are economically disadvantaged',
          feed_name: 'percent-economically-disadvantaged',
          attributes: [:universal_id, :value, :year]
        },
        {
          key: 'Ratio of teacher salary to total number of teachers',
          feed_name: 'average-salary',
          attributes: [:universal_id, :value, :year],
          formatting: [:to_f, :round, 2]
        },
        {
          key: 'Percentage of full time teachers who are certified',
          feed_name: 'percentage-of-full-time-teachers-who-are-certified',
          attributes: [:universal_id, :value, :year],
          formatting: [:to_f, :round, 2]
        },
        {
          key: 'Percentage of teachers with less than three years experience',
          feed_name: 'percentage-of-teachers-with-3-or-more-years-experience',
          attributes: [:universal_id, :value, :year],
          formatting: [:to_f, :inverse_of_100, :round, 2]
        },
        {
          key: 'Ratio of students to full time counselors',
          feed_name: 'student-counselor-ratio',
          attributes: [:universal_id, :value, :year],
          formatting: [:to_f, :round, 2]
        },
        {
          key: 'Female',
          feed_name: 'percentage-female',
          attributes: [:universal_id, :value, :year],
          formatting: [:to_f, :round, 1]
        },
        {
          key: 'Male',
          feed_name: 'percentage-male',
          attributes: [:universal_id, :value, :year],
          formatting: [:to_f, :round, 1]
        },
        {
          key: 'Ethnicity',
          feed_name: 'ethnicity',
          attributes: [:universal_id, :name, :value, :year],
          formatting: [:to_f, :round, 1]
        }
      ].freeze

      def all_feeds
        %w(test_scores test_subgroup test_rating official_overall directory_feed city proficiency_band feed_test_scores_gsdata feed_test_scores_subgroup_gsdata)
      end

      def all_states
        States.abbreviations
      end

      def state_fips
        self.class.send(:state_fips)
      end

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def state_fips
          state_fips = {}
          state_fips['AL'] = '01'
          state_fips['AK'] = '02'
          state_fips['AZ'] = '04'
          state_fips['AR'] = '05'
          state_fips['CA'] = '06'
          state_fips['CO'] = '08'
          state_fips['CT'] = '09'
          state_fips['DE'] = '10'
          state_fips['DC'] = '11'
          state_fips['FL'] = '12'
          state_fips['GA'] = '13'
          state_fips['HI'] = '15'
          state_fips['ID'] = '16'
          state_fips['IL'] = '17'
          state_fips['IN'] = '18'
          state_fips['IA'] = '19'
          state_fips['KS'] = '20'
          state_fips['KY'] = '21'
          state_fips['LA'] = '22'
          state_fips['ME'] = '23'
          state_fips['MD'] = '24'
          state_fips['MA'] = '25'
          state_fips['MI'] = '26'
          state_fips['MN'] = '27'
          state_fips['MS'] = '28'
          state_fips['MO'] = '29'
          state_fips['MT'] = '30'
          state_fips['NE'] = '31'
          state_fips['NV'] = '32'
          state_fips['NH'] = '33'
          state_fips['NJ'] = '34'
          state_fips['NM'] = '35'
          state_fips['NY'] = '36'
          state_fips['NC'] = '37'
          state_fips['ND'] = '38'
          state_fips['OH'] = '39'
          state_fips['OK'] = '40'
          state_fips['OR'] = '41'
          state_fips['PA'] = '42'
          state_fips['RI'] = '44'
          state_fips['SC'] = '45'
          state_fips['SD'] = '46'
          state_fips['TN'] = '47'
          state_fips['TX'] = '48'
          state_fips['UT'] = '49'
          state_fips['VT'] = '50'
          state_fips['VA'] = '51'
          state_fips['WA'] = '53'
          state_fips['WV'] = '54'
          state_fips['WI'] = '55'
          state_fips['WY'] = '56'
          state_fips
        end
      end

  end
end

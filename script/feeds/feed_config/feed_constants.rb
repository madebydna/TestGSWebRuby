module Feeds
  module FeedConstants
      FEED_CACHE_KEYS = %w(feed_test_scores ratings)

      DIRECTORY_FEED_SCHOOL_CACHE_KEYS = %w(directory feed_characteristics)

      DIRECTORY_FEED_DISTRICT_CACHE_KEYS = %w(district_directory feed_district_characteristics)

      WITH_NO_BREAKDOWN = 'with_no_breakdown'

      WITH_ALL_BREAKDOWN = 'wth_all_breakdown'

      FEED_NAME_MAPPING = {
          'test_scores' => 'local-gs-test-feed',
          'test_subgroup' => 'local-gs-test-subgroup-feed',
          'test_rating' => 'local-gs-test-rating-feed',
          'official_overall' => 'local-gs-official-overall-rating-feed',
          'official_overall' => 'local-greatschools-feed'
      }

      RATINGS_ID_RATING_FEED_MAPPING = {
          'test_rating' => 164,
          'official_overall' => 174
      }

      DATA_TYPE_TEST_SCORE_FEED_MAPPING = {
          'test_scores' => WITH_NO_BREAKDOWN,
          'test_subgroup' => WITH_ALL_BREAKDOWN,
      }

      FEED_TO_SCHEMA_MAPPING = {
          'common_schema' => 'http://www.greatschools.org/feeds/greatschools-common.xsd',
          'test_scores' => 'http://www.greatschools.org/feeds/greatschools-test.xsd',
          'test_subgroup' => 'http://www.greatschools.org/feeds/greatschools-test-subgroup.xsd',
          'test_rating' => 'http://www.greatschools.org/feeds/greatschools-test-rating.xsd',
          'official_overall' => 'http://www.greatschools.org/feeds/greatschools-test-rating.xsd',
          'directory_feed' => 'https://www.greatschools.org/feeds/local-greatschools.xsd'
      }
      FEED_TO_ROOT_ELEMENT_MAPPING = {
          'test_scores' => 'gs-test-feed',
          'test_subgroup' => 'gs-test-subgroup-feed',
          'test_rating' => 'gs-test-rating-feed',
          'official_overall' => 'gs-official-overall-rating-feed',
          'directory_feed' => 'gs-local-feed'
      }

      PROFICIENT_AND_ABOVE_BAND = 'proficient and above'

      ENTITY_TYPE_SCHOOL = 'school'


      ENTITY_TYPE_DISTRICT = 'district'

      ENTITY_TYPE_STATE = 'state'

      DEFAULT_BATCH_SIZE = 1

      # this is the required order for school and district content
      DIRECTORY_FEED_FORCE_ORDER = %w(universal_id id state_id nces_code name description street city state zip county fipscounty level level_code district_id lat lon phone fax web_site subtype type district_name universal_district_id district_spending url census_info school_summary)

      # this is a white list of keys we are looking for
      DIRECTORY_KEYS_REQUIRED = %w(id name description street city state county level level_code district_id lat lon subtype type)
      # DIRECTORY_KEYS = %w(nces_code FIPScounty phone fax district_name district-spending school_summary)

      #  REQUIRED - universal_id zipcode home_page_url url
      DIRECTORY_KEYS_SPECIAL = %w(universal_id zipcode home_page_url url state_id universal_district_id census_info)

      # this is a white list of keys we are looking for - executes a method to handle type of data
      CHARACTERISTICS_MAPPING = [
          {
              key: 'Enrollment',
              method: 'enrollment'
          },
          {
              key: 'Ethnicity',
              method: 'ethnicity'
          },
          {
              key: 'Students participating in free or reduced-price lunch program',
              method: 'free_or_reduced_lunch_program'
          },
          {
              key: 'Head official name',
              method: 'straight_text_value',
              data_type: 'head-official-name'
          },
          {
              key: 'Head official email address',
              method: 'straight_text_value',
              data_type: 'head-official-email'
          },
          {
              key: 'English learners',
              method: 'students_with_limited_english_proficiency'
          },
          {
              key: 'Student teacher ratio',
              method: 'student_teacher_ratio'
          },
          {
              key: 'Students who are economically disadvantaged',
              method: 'percent_economically_disadvantaged'
          },
          {
              key: 'Average years of teacher experience',
              method: 'teacher_data',
              data_type: 'average teacher experience years'
          },
          {
              key: 'Average years of teaching in district',
              method: 'teacher_data',
              data_type: 'average years teaching in district'
          },
          {
              key: 'Percent classes taught by highly qualified teachers',
              method: 'teacher_data',
              data_type: 'percent classes taught by highly qualified teachers'
          },
          {
              key: 'Percent classes taught by non-highly qualified teachers',
              method: 'teacher_data',
              data_type: 'percent classes taught by non highly qualified teachers'
          },
          {
              key: 'Percentage of teachers in their first year',
              method: 'teacher_data',
              data_type: 'percent teachers in first year'
          },
          {
              key: 'Teaching experience 0-3 years',
              method: 'teacher_data',
              data_type: 'percent teachers with 3 years or less experience'
          },
          {
              key: 'at least 5 years teaching experience',
              method: 'teacher_data',
              data_type: 'percent teachers with at least 5 years experience'
          },
          {
              key: "Bachelor's degree",
              method: 'teacher_data',
              data_type: 'percent teachers with bachelors degree'
          },
          {
              key: "Doctorate's degree",
              method: 'teacher_data',
              data_type: 'percent teachers with doctorate degree'
          },
          {
              key: "Master's degree",
              method: 'teacher_data',
              data_type: 'percent teachers with masters degree'
          },
          {
              key: "Master's degree or higher",
              method: 'teacher_data',
              data_type: 'percent teachers with masters or higher'
          },
          {
              key: 'Teachers with no valid license',
              method: 'teacher_data',
              data_type: 'percent teachers with no valid license'
          },
          {
              key: 'Other degree',
              method: 'teacher_data',
              data_type: 'percent teachers with other degree'
          },
          {
              key: 'Teachers with valid license',
              method: 'teacher_data',
              data_type: 'percent teachers with valid license'
          }
      ].freeze

      def all_feeds
        %w(test_scores test_subgroup test_rating official_overall, directory_feed)
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

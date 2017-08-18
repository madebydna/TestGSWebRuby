module Feeds
  module FeedConstants
      FEED_CACHE_KEYS = %w(feed_test_scores ratings)

      WITH_NO_BREAKDOWN = 'with_no_breakdown'

      WITH_ALL_BREAKDOWN = 'wth_all_breakdown'

      FEED_NAME_MAPPING = {
          'test_scores' => 'local-gs-test-feed',
          'test_subgroup' => 'local-gs-test-subgroup-feed',
          'test_rating' => 'local-gs-test-rating-feed',
          'official_overall' => 'local-gs-official-overall-rating-feed'
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
          'official_overall' => 'http://www.greatschools.org/feeds/greatschools-test-rating.xsd'
      }
      FEED_TO_ROOT_ELEMENT_MAPPING = {
          'test_scores' => 'gs-test-feed',
          'test_subgroup' => 'gs-test-subgroup-feed',
          'test_rating' => 'gs-test-rating-feed',
          'official_overall' => 'gs-official-overall-rating-feed'
      }

      PROFICIENT_AND_ABOVE_BAND = 'proficient and above'

      ENTITY_TYPE_SCHOOL = 'school'


      ENTITY_TYPE_DISTRICT = 'district'

      ENTITY_TYPE_STATE = 'state'

      DEFAULT_BATCH_SIZE = 1

      def all_feeds
        %w(test_scores test_subgroup test_rating official_overall)
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

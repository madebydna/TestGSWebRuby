require 'spec_helper'

describe StateFeedRatingCacher do

  describe "#build_hash_for_cache" do
    context 'rating data type id is summary' do
      it 'returns a hash with year, description and SUMMARY_RATING_NAME' do
        state = 'ca'
        cacher = StateFeedRatingCacher.new(state)

        create(:data_set,
               data_type_id: StateFeedRatingCacher::SUMMARY_RATING_DATA_TYPE_ID,
               state:        state,
               date_valid:   Date.new(2019, 1, 1))
        expected_hash = {
          year:        2019,
          description: StateFeedRatingCacher::SUMMARY_DESCRIPTION,
          type:        StateFeedRatingCacher::SUMMARY_RATING_NAME
        }
        allow(Omni::DataSet).to receive(:ratings_type_id).and_return(StateFeedRatingCacher::SUMMARY_RATING_DATA_TYPE_ID)
        expect(cacher.build_hash_for_cache).to eq(expected_hash)
      end
    end

    context 'rating data type id is test scores' do
      it 'returns a hash with year, description and TEST_SCORES_RATING_NAME' do
        state = 'ca'
        cacher = StateFeedRatingCacher.new(state)
        description = 'foo test description'

        create(:data_set,
               data_type_id: StateFeedRatingCacher::TEST_SCORES_RATING_DATA_TYPE_ID,
               state:        state,
               date_valid:   Date.new(2019, 1, 1),
               description: description)
        expected_hash = {
          year:        2019,
          description: description,
          type:        StateFeedRatingCacher::TEST_SCORES_RATING_NAME
        }
        allow(Omni::DataSet).to receive(:ratings_type_id).and_return(StateFeedRatingCacher::TEST_SCORES_RATING_DATA_TYPE_ID)
        expect(cacher.build_hash_for_cache).to eq(expected_hash)
      end
    end
  end
end

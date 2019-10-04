require 'spec_helper'
require 'feeds/feed_helpers/feed_data_helper'
require 'feeds/feed_builders/test_score/feed_test_scores_cache_hash'

describe Feeds::FeedDataHelper do
  class DummyClass
    include Feeds::FeedDataHelper
  end

  after { clean_dbs :gs_schooldb, :ca, :mi }

  before do
    @ca_district_1 = FactoryBot.create_on_shard(:ca, :district)
    @ca_district_2 = FactoryBot.create_on_shard(:ca, :district)
    @mi_district = FactoryBot.create_on_shard(:mi, :district)
    FactoryBot.create(:district_cache, state: 'ca', district_id: @ca_district_1.id, name: 'feed_test_scores')
    FactoryBot.create(:district_cache, state: 'ca', district_id: @ca_district_2.id, name: 'feed_test_scores')
    FactoryBot.create(:district_cache, state: 'mi', district_id: @mi_district.id, name: 'feed_test_scores')
  end

  describe '#get_districts_batch_cache_data' do
    it 'returns decorated districts that respond to #feed_test_scores' do
      results = DummyClass.new.get_districts_batch_cache_data([@ca_district_1, @ca_district_2, @mi_district])
      results.each do |result|
        expect(result).to be_a(DistrictFeedDecorator)
        expect(result).to respond_to(:feed_test_scores)
        expect(result.feed_test_scores).to be_a(FeedTestScoresCacheHash)
      end
    end
  end
end
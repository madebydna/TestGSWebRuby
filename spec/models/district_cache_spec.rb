require "spec_helper"

describe DistrictCache do
  after { clean_dbs :gs_schooldb, :ca, :hi }

  before do
    @district1 = FactoryGirl.create_on_shard(:ca, :district)
    @district2 = FactoryGirl.create_on_shard(:ca, :district)
    @district_cache1 = FactoryGirl.create(:district_cache, state: 'ca', district_id: @district1.id, name: 'feed_test_scores_gsdata')
    @district_cache2 = FactoryGirl.create(:district_cache, state: 'ca', district_id: @district2.id, name: 'ratings')
  end
  
  describe '.for_district' do


    it 'returns correct district given a district record' do
      expect(DistrictCache.for_district(@district1)).to include(@district_cache1)
      expect(DistrictCache.for_district(@district1)).not_to include(@district_cache2)
    end
  end

  describe '.include_cache_keys' do
    before do
      @district3 = FactoryGirl.create_on_shard(:hi, :district)
      @district_cache3 = FactoryGirl.create(:district_cache, district_id: @district3.id, state: 'hi', name: 'ratings')
    end

    it 'returns all cached data for given key' do
      expect(DistrictCache.include_cache_keys('ratings')).to include(@district_cache2, @district_cache3)
      expect(DistrictCache.include_cache_keys('ratings')).not_to include(@district_cache1)
    end

    it 'returns all cached data given multiple keys' do
      expect(DistrictCache.include_cache_keys(%w(ratings feed_test_scores_gsdata))).to include(@district_cache1, @district_cache2, @district_cache3)
    end
  end
end
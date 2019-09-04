require "spec_helper"

describe DistrictCache do
  after { clean_dbs :gs_schooldb, :ca, :hi }

  before do
    @district1 = FactoryBot.create_on_shard(:ca, :district, state: "CA")
    @district2 = FactoryBot.create_on_shard(:ca, :district, state: "CA")
    @district3 = FactoryBot.create_on_shard(:hi, :district, state: "HI")
    @district_cache1 = FactoryBot.create(:district_cache, state: 'ca', district_id: @district1.id, name: 'feed_test_scores_gsdata')
    @district_cache2 = FactoryBot.create(:district_cache, state: 'ca', district_id: @district2.id, name: 'ratings')
    @district_cache3 = FactoryBot.create(:district_cache, district_id: @district3.id, state: 'hi', name: 'ratings')
  end
  
  describe '.for_district' do
    it 'returns correct district given a district record' do
      expect(DistrictCache.for_district(@district1)).to match_array([@district_cache1])
    end
  end

  describe '.include_cache_keys' do
    it 'returns all cached data for given key' do
      expect(DistrictCache.include_cache_keys('ratings')).to match_array([@district_cache2, @district_cache3])
    end

    it 'returns all cached data given multiple keys' do
      expect(DistrictCache.include_cache_keys(%w(ratings feed_test_scores_gsdata))).to include(@district_cache1, @district_cache2, @district_cache3)
    end
  end

  describe '.for_districts' do
    context 'with districts from same state' do
      it 'returns district cache data records for given districts' do
        expect(DistrictCache.for_districts([@district1, @district2])).to include(@district_cache1, @district_cache2)
      end
    end

    context 'with districts from different states' do
      it 'returns district cache data records for given districts' do
        expect(DistrictCache.for_districts([@district1, @district3])).to include(@district_cache1, @district_cache3)
      end
    end

    context 'with empty array' do
      it 'returns no districts' do
        expect(DistrictCache.for_districts([]).empty?).to be_truthy
      end
    end
  end


end
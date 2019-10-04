require 'spec_helper'

describe StateDistrictLargestCacher do
  describe '#district_characteristics' do
    subject(:cacher) { StateDistrictLargestCacher.new('ca') }
    after { clean_dbs :gs_schooldb, :ca }

    before do
      @district = FactoryBot.create_on_shard(:ca, :district)
      @district2 = FactoryBot.create_on_shard(:ca, :district)
      @district_cache = FactoryBot.create(:district_cache, state: 'ca', district_id: @district.id, name: 'district_characteristics')
    end

    it 'should return value of district_characteristics DistrictCache given a district_id' do
      expect(cacher.district_characteristics(@district.id)).to eq(@district_cache.value)
    end

    it 'should return nil for non-existing district_characteristics cache' do
      expect(cacher.district_characteristics(@district2.id)).to be nil
    end
  end
end
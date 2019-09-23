require 'spec_helper'

describe StateCache do
  after { clean_dbs :gs_schooldb, :ca, :ar, :id }

  before do
    @state_cache = FactoryBot.create(:state_cache, state: 'ca', name: 'gsdata')
    FactoryBot.create(:state_cache, state: 'ca', name: 'state_attributes', value: "{\"growth_type\":\"Academic Progress Rating\"}")
    FactoryBot.create(:state_cache, state: 'ca', name: 'test_scores_gsdata')
    FactoryBot.create(:state_cache, state: 'ar', name: 'state_attributes', value: "{\"growth_type\":\"Student Progress Rating\"}")
    FactoryBot.create(:state_cache, state: 'id', name: 'state_attributes')
  end

  describe '.for_state' do
    it 'returns correct state cache record given a state' do
      expect(StateCache.for_state('gsdata', 'CA')).to eq(@state_cache)
    end

    it 'returns nil if record not found' do
      expect(StateCache.for_state('gsdata', 'KS')).to be_nil
    end
  end

  describe 'for_state_keys' do
    data_hash =  {"ca"=>{"state_attributes"=>{"growth_type"=>"Academic Progress Rating"}, "gsdata"=>{}}, "ar"=>{"state_attributes"=>{"growth_type"=>"Student Progress Rating"}}}
    it 'returns the correct hash object when given state and keys' do
      expect(StateCache.for_state_keys(%w(state_attributes gsdata), %w(ar ca))).to eq(data_hash)
    end
  end

  describe '#cache_data' do
    subject {StateCache.for_state('state_attributes', 'CA') }
    it 'returns the cache data payload when entry is found' do
      payload = {"growth_type"=>"Academic Progress Rating"}
      expect(subject.cache_data).to eq(payload)
    end

    it 'returns rescued empty hash if no cache value is found' do
      expect(StateCache.for_state('state_attributes', 'id').cache_data).to eq({})
    end
  end
end
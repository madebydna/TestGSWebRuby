require 'spec_helper'

describe Cacher do
  let(:school) { FactoryBot.build(:alameda_high_school) }
  let(:cacher) { Cacher.new(school) }

  describe '#cache' do
    let(:sample_json) do
      {
        foo: 'bar'
      }
    end
    let(:school) { FactoryBot.build(:school) }
    let(:cache_key) { 'test_cache_key' }
    subject { cacher }
    after do
      clean_dbs(:gs_schooldb)
    end
    before do
      stub_const('Cacher::CACHE_KEY', cache_key)
    end

    context 'with a cache data for a school' do
      before do
        allow(subject).to receive(:build_hash_for_cache).and_return(sample_json)
        allow(subject).to receive(:school).and_return(school)
      end
      it 'writes a single cache entry' do
        expect(SchoolCache.count).to eq(0)
        subject.cache
        expect(SchoolCache.count).to eq(1)
        subject.cache
        expect(SchoolCache.count).to eq(1)
        saved_cache_entry = SchoolCache.first
        expect(saved_cache_entry.value).to eq(sample_json.to_json)
        expect(saved_cache_entry.school_id).to eq(school.id)
        expect(saved_cache_entry.state).to eq(school.state)
        expect(saved_cache_entry.name).to eq(cache_key)
      end
      it 'maintains auto increment ID' do
        expect(SchoolCache.count).to eq(0)
        subject.cache
        expect(SchoolCache.count).to eq(1)
        id = SchoolCache.first.id
        subject.cache
        expect(SchoolCache.count).to eq(1)
        expect(SchoolCache.first.id).to eq(id)
      end
    end

    context 'with no cache data for a school and an existing entry' do
      before do
        allow(subject).to receive(:build_hash_for_cache).and_return(sample_json)
        allow(subject).to receive(:school).and_return(school)
        subject.cache
        allow(subject).to receive(:build_hash_for_cache).and_return({})
      end
      it 'removes a cache entry if data for school no longer exists' do
        expect(SchoolCache.count).to eq(1)
        subject.cache
        expect(SchoolCache.count).to eq(0)
      end
    end
  end

  describe '#cachers_for_data_type' do
    {
      esp_response: [EspResponsesCaching::EspResponsesCacher],
      school_reviews: [ReviewsCaching::ReviewsSnapshotCacher],
      metrics: [MetricsCaching::SchoolMetricsCacher],
      test_scores: [TestScoresCaching::TestScoresCacherGsdata, TestScoresCaching::Feed::FeedTestScoresCacherGsdata, TestScoresCaching::Feed::FeedOldTestScoresCacherGsdata],
      gsdata: [GsdataCaching::GsdataCacher],
    }.each do |data_type, cacher_list|
      it "handles the data type #{data_type}" do
        rval = Cacher.cachers_for_data_type data_type
        cacher_list.each { |cacher| expect(rval).to include(cacher)}
        expect(rval.size).to eq(cacher_list.size)
      end
    end
  end

  describe '#create_caches_for_data_type' do
    it 'handles :esp_response as expected' do
      esp_cacher = Object.new
      expect(EspResponsesCaching::EspResponsesCacher).to receive(:new).and_return esp_cacher
      expect(esp_cacher).to receive(:cache)
      expect(ReviewsCaching::ReviewsSnapshotCacher).to_not receive(:new)
      expect(MetricsCaching::SchoolMetricsCacher).to_not receive(:new)
      Cacher.create_caches_for_data_type(school, :esp_response)
    end
    it 'handles exception in one cacher without affecting others' do
      esp_cacher = Object.new
      expect(EspResponsesCaching::EspResponsesCacher).to receive(:new).and_raise "Error caching esp_response"
      expect(esp_cacher).to_not receive(:cache)
      Cacher.create_caches_for_data_type(school, :esp_response)
    end
  end
end

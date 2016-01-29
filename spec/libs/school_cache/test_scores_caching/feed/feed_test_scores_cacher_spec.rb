require 'spec_helper'

describe FeedTestScoresCacher do
  let(:school) { FactoryGirl.build(:alameda_high_school) }
  let(:subject) { FeedTestScoresCacher.new(school) }

  describe '#query_results' do
    let(:test_data_types) {{17 => true, 19 => true, 21 => true}}

    it 'should call feed-specific methods on TestDataSet' do
      allow(TestDataSet).to receive(:fetch_feed_test_scores).and_return []
      expect(TestDataSet).not_to receive(:fetch_test_scores)
      expect(subject.query_results).to be_empty
    end

    it 'should keep only known data type ids' do
      allow(subject).to receive(:test_data_types).and_return(test_data_types)
      FakeQueryResults = Struct.new(:data_type_id)
      expect(TestDataSet).to receive(:fetch_feed_test_scores).and_return(
          [FakeQueryResults.new(17), FakeQueryResults.new(18), FakeQueryResults.new(19)])
      expect(subject.query_results).not_to be_empty
      expect(subject.query_results.map {|q| q.data_type_id}.sort).to eq([17,19])
    end
  end

  describe '.active' do
    it 'defaults to false' do
      stub_const('ENV_GLOBAL', {})
      expect(FeedTestScoresCacher.active?).to be_falsey
    end
    it 'is false if env var is false' do
      stub_const('ENV_GLOBAL', {'is_feed_builder' => false})
      expect(FeedTestScoresCacher.active?).to be_falsey
    end
    it 'is false if env var is \'false\'' do
      stub_const('ENV_GLOBAL', {'is_feed_builder' => 'false'})
      expect(FeedTestScoresCacher.active?).to be_falsey
    end
    it 'is true if env var is true' do
      stub_const('ENV_GLOBAL', {'is_feed_builder' => true})
      expect(FeedTestScoresCacher.active?).to be_truthy
    end
    it 'is true if env var is \'true\'' do
      stub_const('ENV_GLOBAL', {'is_feed_builder' => 'true'})
      expect(FeedTestScoresCacher.active?).to be_truthy
    end
  end
end


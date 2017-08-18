require 'spec_helper'
require 'feeds/feed_builders/test_score/test_score_feed'

describe Feeds::TestScoreFeed do

  let(:attributes) do
    {
      state: 'ca',
      district_ids: 1,
      school_ids: 1,
      feed_file_path: '/foo',
      root_element: 'root-element',
      schema: 'foo.xsd',
      data_type: 'WITH_ALL_BREAKDOWN',
      batch_size: 1
    }
  end

  let(:mock_file) { StringIO.new }

  let(:test_score_feed) do
    tsf = Feeds::TestScoreFeed.new(attributes)
    tsf.school_feed = school_feed
    tsf.district_feed = district_feed
    tsf.state_feed = state_feed

    allow(tsf).to receive(:file).and_return(mock_file)
    tsf
  end

  let(:school_feed_results) { [] }
  let(:school_feed) do
    sf = double() 
    allow(sf).to receive(:each_result).and_yield(school_feed_results)
    sf
  end

  let(:state_feed_results) { [] }
  let(:state_feed) do
    sf = double() 
    allow(sf).to receive(:each_result).and_yield(state_feed_results)
    sf
  end

  let(:district_feed_results) { [] }
  let(:district_feed) do
    f = double() 
    allow(f).to receive(:each_result).and_yield(district_feed_results)
    f
  end

  subject do
    test_score_feed.generate_feed
    mock_file.string
  end

  context 'with a school feed that just contains one hash with foo:bar' do
    let(:school_feed_results) do
      [
        {
          foo: :bar
        }
      ]
    end
    it { is_expected.to start_with('<?xml version="1.0" encoding="utf-8"?>') }
    it { is_expected.to match('<root-element xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="foo.xsd">') }
    it { is_expected.to match('<test-result>') }
    it { is_expected.to match('</test-result>') }
    it { is_expected.to match('foo:bar') }

    it 'should close the file' do
      allow(mock_file).to receive(:close).and_return(nil)
      subject
      expect(mock_file).to have_received(:close)
    end
  end

  context 'with a district feed that just contains one hash with foo:bar' do
    let(:district_feed_results) do
      [
        {
          foo: :bar
        }
      ]
    end
    it { is_expected.to start_with('<?xml version="1.0" encoding="utf-8"?>') }
    it { is_expected.to match('<root-element xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="foo.xsd">') }
    it { is_expected.to match('<test-result>') }
    it { is_expected.to match('</test-result>') }
    it { is_expected.to match('foo:bar') }
  end

  context 'with a school feed that returns 2 items' do
    let(:school_feed_results) do
      [
        {
          a: :foo
        },
        {
          b: :bar
        }
      ]
    end

    it 'should have 4 occurences of tag name' do
      subject
      expect(mock_file.string.scan(/<\/?test-result>/).count).to eq(4)
    end
  end

end

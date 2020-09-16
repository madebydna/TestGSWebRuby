require 'spec_helper'
require 'feeds/feed_scripts/feed_generator'

describe Feeds::FeedGenerator do
  describe '#generate' do
    context 'directory feed' do
      before do
        parser = double('parser', {
          parse!: {
            state: "ca",
            formats: [:xml],
            path: "foo/bar/",
            feed: "directory_feed"
          }
        })
        allow(Feeds::FeedsOptionParser).to receive(:new).and_return(parser)
      end
      subject { Feeds::FeedGenerator.new }

      it 'calls write_feed with the state and format specified' do
        expect(subject).to receive(:write_feed).with("ca", :xml)
        subject.generate
      end
    end

  end
end
require 'spec_helper'
require 'feeds/feed_helpers/arguments'

describe Feeds::Arguments do
  let(:arguments) { Feeds::Arguments.new(input_argument_string) }
  let(:input_argument_string) { nil }
  subject { arguments }

  context 'when given "all" as the only argument' do
    let(:input_argument_string) { 'all' }
    its(:states) { is_expected.to eq(States.abbreviations) }
    its(:feed_names) { is_expected.to eq(subject.all_feeds) }
    its(:batch_size) { is_expected.to eq(Feeds::FeedConstants::DEFAULT_BATCH_SIZE) }
  end

  context 'when specifying state as "all"' do
    let(:input_argument_string) { build_arguments(states: 'all') }
    its(:states) { is_expected.to eq(States.abbreviations) }
  end

  context 'when specifying state as "ca"' do
    let(:input_argument_string) { build_arguments(states: 'ca') }
    its(:states) { is_expected.to eq(['ca']) }
  end

  context 'when specifying state as "CA"' do
    let(:input_argument_string) { build_arguments(states: 'CA') }
    its(:states) { is_expected.to eq(['CA']) }
  end

  context 'when specifying feed_names as "all"' do
    let(:input_argument_string) { build_arguments(feed_names: 'all') }
    its(:feed_names) { is_expected.to eq(subject.all_feeds) }
  end

  context 'when specifying school_ids as nil' do
    let(:input_argument_string) { build_arguments(school_ids: nil) }
    its(:school_ids) { is_expected.to be_nil }
  end

  context 'when specifying school_ids as 1,2,3' do
    let(:input_argument_string) { build_arguments(school_ids: '1,2,3') }
    its(:school_ids) { is_expected.to eq(['1','2','3']) }
  end

  context 'when specifying district_ids as nil' do
    let(:input_argument_string) { build_arguments(district_ids: nil) }
    its(:district_ids) { is_expected.to be_nil }
  end

  context 'when specifying district_ids as 1,2,3' do
    let(:input_argument_string) { build_arguments(district_ids: '1,2,3') }
    its(:district_ids) { is_expected.to eq(['1','2','3']) }
  end

  context 'when specifying locations as nil' do
    let(:input_argument_string) { build_arguments(locations: nil) }
    its(:locations) { is_expected.to be_nil }
  end

  context 'when specifying locations as /foo,/bar' do
    let(:input_argument_string) { build_arguments(locations: '/foo,/bar') }
    its(:locations) { is_expected.to eq(['/foo', '/bar']) }
  end

  context 'when specifying names as nil' do
    let(:input_argument_string) { build_arguments(names: nil) }
    its(:names) { is_expected.to be_nil }
  end

  context 'when specifying names as foo,bar' do
    let(:input_argument_string) { build_arguments(names: 'foo,bar') }
    its(:names) { is_expected.to eq(['foo', 'bar']) }
  end

  context 'when specifying batch_size as nil' do
    let(:input_argument_string) { build_arguments(batch_size: nil) }
    its(:batch_size) { is_expected.to eq(Feeds::FeedConstants::DEFAULT_BATCH_SIZE) }
  end

  context 'when specifying batch_size as 123' do
    let(:input_argument_string) { build_arguments(batch_size: '123') }
    its(:batch_size) { is_expected.to eq('123') }
  end

  def build_arguments(hash)
    arg_array = []
    arg_array << (hash[:feed_names] || 'test_scores')
    arg_array << (hash[:states] || 'ca')
    arg_array << (hash[:school_ids] || '')
    arg_array << (hash[:district_ids] || '')
    arg_array << (hash[:locations] || '')
    arg_array << (hash[:names] || '')
    arg_array << (hash[:batch_size] || '')
    arg_string = arg_array.join(':')
    arg_string
  end

end

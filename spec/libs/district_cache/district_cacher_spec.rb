# frozen_string_literal: true

require 'spec_helper'

describe DistrictCacher do
  describe '.cachers_for_data_type' do
    subject { DistrictCacher.cachers_for_data_type(data_type) }
    let(:data_type) { 'directory' }

    it 'delegates to registered_cachers' do
      expect(DistrictCacher).to receive(:registered_cachers).and_return([])
      subject
    end

    {
        metrics: [DistrictMetricsCacher],
        census: [DistrictCharacteristicsCacher],
        directory: [DistrictDirectoryCacher],
    }.each do |data_type, expected_cacher_list|
      context "with data type '#{data_type}'" do
        let(:data_type) { data_type }

        it { is_expected.to eq(expected_cacher_list) }
      end
    end
  end

  describe '.create_caches_for_data_type' do
    subject { DistrictCacher.create_caches_for_data_type(District.new, 'irrelevant') }

    it 'looks up the appropriate cachers using #cachers_for_data_type' do
      expect(DistrictCacher).to receive(:cachers_for_data_type).with('irrelevant').and_return([])
      subject
    end

    it 'handles exception in one cacher without affecting others' do
      fake_cacher1 = double
      fake_cacher2 = double
      expect(DistrictCacher).to receive(:cachers_for_data_type).and_return([fake_cacher1, fake_cacher2])

      expect(fake_cacher1).to receive(:active?).and_return(true)
      expect(fake_cacher2).to receive(:active?).and_return(true)
      expect(fake_cacher1).to receive(:new).and_raise(StandardError)

      expect(fake_cacher2).to receive(:new).and_return(fake_cacher2)
      expect(fake_cacher2).to receive(:cache)

      subject
    end
  end
end

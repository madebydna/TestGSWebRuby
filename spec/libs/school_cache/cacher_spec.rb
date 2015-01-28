require 'spec_helper'

describe Cacher do
  let(:school) { FactoryGirl.build(:alameda_high_school) }

  describe '#cachers_for_data_type' do
    {
      esp_response: [EspResponsesCaching::EspResponsesCacher, ProgressBarCaching::ProgressBarCacher],
      school_reviews: [ReviewsCaching::ReviewsSnapshotCacher, ProgressBarCaching::ProgressBarCacher],
      school_media: [ProgressBarCaching::ProgressBarCacher],
      census: [CharacteristicsCaching::CharacteristicsCacher]
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
      progress_cacher = Object.new
      expect(ProgressBarCaching::ProgressBarCacher).to receive(:new).and_return progress_cacher
      expect(progress_cacher).to receive(:cache)
      expect(ReviewsCaching::ReviewsSnapshotCacher).to_not receive(:new)
      expect(CharacteristicsCaching::CharacteristicsCacher).to_not receive(:new)
      Cacher.create_caches_for_data_type(school, :esp_response)
    end
    it 'handles exception in one cacher without affecting others' do
      esp_cacher = Object.new
      expect(EspResponsesCaching::EspResponsesCacher).to receive(:new).and_raise "Error caching esp_response"
      expect(esp_cacher).to_not receive(:cache)
      progress_cacher = Object.new
      expect(ProgressBarCaching::ProgressBarCacher).to receive(:new).and_return progress_cacher
      expect(progress_cacher).to receive(:cache)
      Cacher.create_caches_for_data_type(school, :esp_response)
    end
  end
end
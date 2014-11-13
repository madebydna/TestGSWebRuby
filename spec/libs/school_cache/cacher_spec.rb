require 'spec_helper'

describe Cacher do
  let(:school) { FactoryGirl.build(:alameda_high_school) }

  describe '#cacher_dependencies_for'do
    it "esp_responses should return ProgressBarCaching " do
      expect(Cacher.cacher_dependencies_for("esp_responses")).to eq([ProgressBarCaching::ProgressBarCacher])
    end
    it "test_scores should return no depdencies " do
      expect(Cacher.cacher_dependencies_for("test_scores")).to eq(nil)
    end
    it "characterstics should return no depdencies " do
      expect(Cacher.cacher_dependencies_for("characterstics")).to eq(nil)
    end
    it "reviews_snapshot should return no depdencies " do
      expect(Cacher.cacher_dependencies_for("reviews_snapshot")).to eq(nil)
    end
    it "progress_bar should return no depdencies " do
      expect(Cacher.cacher_dependencies_for("reviews_snapshot")).to eq(nil)
    end
  end
end
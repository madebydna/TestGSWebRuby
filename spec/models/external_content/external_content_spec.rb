require 'spec_helper'

describe ExternalContent do

  subject { ExternalContent }

  [
    :homepage_features
  ].each do |content_key|
    it { is_expected.to respond_to content_key }
    it { is_expected.to respond_to "#{content_key}_content" }
  end

  describe '.homepage_features' do
    before do
      FactoryGirl.create(:homepage_features_external_content)
    end
    after do
      clean_models :gs_schooldb, ExternalContent
    end
    subject { ExternalContent.homepage_features }

    it { is_expected.to be_a HomepageFeatures }
    its(:first_feature) { is_expected.to be_present }
  end

  describe '.homepage_features_content' do
    before do
      FactoryGirl.create(:homepage_features_external_content)
    end
    after do
      clean_models :gs_schooldb, ExternalContent
    end
    subject { ExternalContent.homepage_features_content }

    it { is_expected.to be_a Hash }
  end

end
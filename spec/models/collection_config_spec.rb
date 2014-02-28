require 'spec_helper'

shared_examples "it rejects empty configs" do
  it 'returns nil' do
    described_class.send(method, [])
  end
end

describe CollectionConfig do
  describe '.featured_articles' do
    it_behaves_like 'it rejects empty configs' do
      let(:method) { :featured_articles }
    end
  end

  describe '.city_hub_partners' do
    it_behaves_like 'it rejects empty configs' do
      let(:method) { :city_hub_partners }
    end
  end

  describe '.city_hub_sponsor' do
    it_behaves_like 'it rejects empty configs' do
      let(:method) { :city_hub_sponsor }
    end
  end

  describe '.city_hub_choose_school' do
    it_behaves_like 'it rejects empty configs' do
      let(:method) { :city_hub_choose_school }
    end
  end

  describe '.city_hub_announcement' do
    it_behaves_like 'it rejects empty configs' do
      let(:method) { :city_hub_announcement }
    end
  end

  describe '.city_hub_important_events' do
    it_behaves_like 'it rejects empty configs' do
      let(:method) { :city_hub_important_events }
    end
  end
end

require 'spec_helper'

shared_examples "it rejects empty configs" do
  it 'returns nil' do
    result = described_class.send(method, [])
    expect(result).to be_nil
  end
end

shared_examples "it fails with an error" do
  context 'invalid json string' do
    before(:each) { HubCityMapping.destroy_all; CollectionConfig.destroy_all }

    it 'returns nil' do
      FactoryGirl.create(:bogus_collection_config, quay: key)
      collection_configs = described_class.where(collection_id: 1, quay: key)
      result = described_class.send(method, collection_configs)

      expect(result).to be_nil
    end

    it 'logs an error' do
      Rails.logger.should_receive(:error)
      collection_configs = described_class.where(collection_id: 1, quay: key)
      FactoryGirl.create(:bogus_collection_config, quay: key)

      result = described_class.send(method, collection_configs)
    end
  end
end

describe CollectionConfig do
  after(:each) { HubCityMapping.destroy_all; CollectionConfig.destroy_all }

  describe '.featured_articles' do
    it_behaves_like 'it rejects empty configs' do
      let(:method) { :featured_articles }
    end

    it_behaves_like 'it fails with an error' do
      let(:key) { CollectionConfig::FEATURED_ARTICLES_KEY }
      let(:method) { :featured_articles }
    end

    context 'valid json string' do
      before(:each) { FactoryGirl.create(:feature_articles_collection_config) }

      it 'parses the articles and returns an array' do
        collection_configs = CollectionConfig.where(collection_id: 1, quay: CollectionConfig::FEATURED_ARTICLES_KEY)
        result = CollectionConfig.featured_articles(collection_configs)

        expect(result).to be_an_instance_of(Array)
      end
      it 'adds the cdn host to each articleImagePath' do
        collection_configs = CollectionConfig.where(collection_id: 1, quay: CollectionConfig::FEATURED_ARTICLES_KEY)
        result = CollectionConfig.featured_articles(collection_configs)

        expect(result.first[:articleImagePath]).to start_with(CollectionConfig::CDN_HOST)
      end
    end
  end

  describe '.city_hub_partners' do
    it_behaves_like 'it rejects empty configs' do
      let(:method) { :city_hub_partners }
    end

    it_behaves_like 'it fails with an error' do
      let(:key) { CollectionConfig::CITY_HUB_PARTNERS_KEY }
      let(:method) { :city_hub_partners }
    end


    context 'valid json string' do
      before(:each) { FactoryGirl.create(:city_hub_partners_collection_config) }

      it 'parses the partners string and returns a hash' do
        collection_configs = CollectionConfig.where(collection_id: 1, quay: CollectionConfig::CITY_HUB_PARTNERS_KEY)
        result = CollectionConfig.city_hub_partners(collection_configs)

        expect(result).to be_an_instance_of(Hash)
      end

      it 'sets the link and path for partners' do
        collection_configs = CollectionConfig.where(collection_id: 1, quay: CollectionConfig::CITY_HUB_PARTNERS_KEY)
        result = CollectionConfig.city_hub_partners(collection_configs)

        expect(result[:partnerLogos].first[:logoPath]).to start_with(CollectionConfig::CDN_HOST)
        expect(result[:partnerLogos].first[:anchoredLink]).to start_with('education-community')
      end
    end
  end

  describe '.city_hub_sponsor' do
    it_behaves_like 'it rejects empty configs' do
      let(:method) { :city_hub_sponsor }
    end

    it_behaves_like 'it fails with an error' do
      let(:key) { CollectionConfig::CITY_HUB_SPONSOR_KEY }
      let(:method) { :city_hub_sponsor }
    end

    context 'valid json string' do
      it 'parses the sponsors string and returns an array' do
        FactoryGirl.create(:city_hub_sponsor_collection_config)
        collection_configs = CollectionConfig.where(collection_id: 1, quay: CollectionConfig::CITY_HUB_SPONSOR_KEY)
        result = CollectionConfig.city_hub_sponsor(collection_configs)

        expect(result).to be_an_instance_of(Hash)
      end
    end
  end

  describe '.city_hub_choose_school' do
    it_behaves_like 'it rejects empty configs' do
      let(:method) { :city_hub_choose_school }
    end

    it_behaves_like 'it fails with an error' do
      let(:key) { CollectionConfig::CITY_HUB_CHOOSE_A_SCHOOL_KEY }
      let(:method) { :city_hub_choose_school }
    end

    context 'valid json string' do
      it 'parses the choose school string and returns a hash' do
        FactoryGirl.create(:school_collection_config)
        collection_configs = CollectionConfig.where(collection_id: 1, quay: CollectionConfig::CITY_HUB_CHOOSE_A_SCHOOL_KEY)
        result = CollectionConfig.city_hub_choose_school(collection_configs)

        expect(result).to be_an_instance_of(Hash)
      end
    end
  end

  describe '.city_hub_announcement' do
    it_behaves_like 'it rejects empty configs' do
      let(:method) { :city_hub_announcement }
    end

    it_behaves_like 'it fails with an error' do
      let(:key) { CollectionConfig::CITY_HUB_ANNOUNCEMENT_KEY }
      let(:method) { :city_hub_announcement }
    end


    context 'valid json string' do
      it 'parses the announcement string and returns a hash' do
        FactoryGirl.create(:announcement_collection_config)
        FactoryGirl.create(:show_announcement_collection_config)
        collection_configs = CollectionConfig.where(collection_id: 1)
        result = CollectionConfig.city_hub_announcement(collection_configs)

        expect(result).to be_an_instance_of(Hash)
      end
    end
  end

  describe '.city_hub_important_events' do
    before do
      Timecop.freeze(Date.new(2014, 2, 27))
    end

    after do
      Timecop.return
    end

    it_behaves_like 'it rejects empty configs' do
      let(:method) { :city_hub_important_events }
    end

    it_behaves_like 'it fails with an error' do
      let(:key) { CollectionConfig::CITY_HUB_IMPORTANT_EVENTS_KEY }
      let(:method) { :city_hub_important_events }
    end


    context 'valid json string' do
      before(:each) { FactoryGirl.create(:important_events_collection_config) }
      it 'parses the important events string and returns a hash' do
        collection_configs = CollectionConfig.where(collection_id: 1, quay: CollectionConfig::CITY_HUB_IMPORTANT_EVENTS_KEY)
        result = CollectionConfig.city_hub_important_events(collection_configs)

        expect(result).to be_an_instance_of(Hash)
      end

      it 'limits to the max number of events' do
        collection_configs = CollectionConfig.where(collection_id: 1, quay: CollectionConfig::CITY_HUB_IMPORTANT_EVENTS_KEY)
        result = CollectionConfig.city_hub_important_events(collection_configs, 1)
        expect(result[:events].length).to eq(1)

        result = CollectionConfig.city_hub_important_events(collection_configs, 2)
        expect(result[:events].length).to eq(2)
      end

      it 'sorts by date' do
        collection_configs = CollectionConfig.where(collection_id: 1, quay: CollectionConfig::CITY_HUB_IMPORTANT_EVENTS_KEY)
        result = CollectionConfig.city_hub_important_events(collection_configs)

        sorted_result = result.clone
        sorted_result[:events].sort_by! { |e| e[:date] }

        expect(result).to eq(sorted_result)
      end

      it 'removes past events' do
        collection_configs = CollectionConfig.where(collection_id: 1, quay: CollectionConfig::CITY_HUB_IMPORTANT_EVENTS_KEY)
        result = CollectionConfig.city_hub_important_events(collection_configs)
        dates = []
        result[:events].each do |event|
          expect(event[:date] >= Date.today).to be_true
        end
      end
    end
  end



  describe '.important_events' do
    before do
      Timecop.freeze(Date.new(2014, 2, 27))
    end

    after do
      Timecop.return
    end

    it_behaves_like 'it rejects empty configs' do
      let(:method) { :important_events }
    end

    it_behaves_like 'it fails with an error' do
      let(:key) { CollectionConfig::CITY_HUB_IMPORTANT_EVENTS_KEY }
      let(:method) { :important_events }
    end


    context 'valid json string' do
      before(:each) { FactoryGirl.create(:important_events_collection_config) }
      it 'parses the important events string and returns an array' do
        result = CollectionConfig.important_events(1)

        expect(result).to be_an_instance_of(Array)
      end

      it 'sorts by date' do
        collection_configs = CollectionConfig.where(collection_id: 1, quay: CollectionConfig::CITY_HUB_IMPORTANT_EVENTS_KEY)
        result = CollectionConfig.city_hub_important_events(collection_configs)

        sorted_result = result.clone
        sorted_result[:events].sort_by! { |e| e[:date] }

        expect(result).to eq(sorted_result)
      end

      it 'removes past events' do
        collection_configs = CollectionConfig.where(collection_id: 1, quay: CollectionConfig::CITY_HUB_IMPORTANT_EVENTS_KEY)
        result = CollectionConfig.city_hub_important_events(collection_configs)
        dates = []
        result[:events].each do |event|
          expect(event[:date] >= Date.today).to be_true
        end
      end
    end
  end

  describe '.ed_community_subheading' do
    it_behaves_like 'it rejects empty configs' do
      let(:method) { :ed_community_subheading }
    end

    context 'valid json string' do
      it 'returns the subheading string' do
        FactoryGirl.create(:community_partners_subheading_collection_config)
        collection_configs = CollectionConfig.where(collection_id: 1, quay: CollectionConfig::EDUCATION_COMMUNITY_SUBHEADING_KEY)
        result = CollectionConfig.ed_community_subheading(collection_configs)

        expect(result).to start_with("Education doesn't happen in a vacuum")
      end
    end
  end

  describe '.ed_community_partners' do
    it_behaves_like 'it rejects empty configs' do
      let(:method) { :ed_community_partners }
    end

    it_behaves_like 'it fails with an error' do
      let(:key) { CollectionConfig::EDUCATION_COMMUNITY_PARTNERS_KEY }
      let(:method) { :ed_community_partners }
    end

    context 'valid json string' do
      before(:each) { FactoryGirl.create(:community_partners_collection_config) }
      it 'returns sorted partners' do
        collection_configs = CollectionConfig.where(collection_id: 1, quay: CollectionConfig::EDUCATION_COMMUNITY_PARTNERS_KEY)
        result = CollectionConfig.ed_community_partners(collection_configs)

        expect(result).to be_an_instance_of(Hash)
        expect(result).to have_key('Community')
        expect(result).to have_key('Education')
        expect(result).to have_key('Funders')
      end

      it 'adds the cdn host to logos' do
        collection_configs = CollectionConfig.where(collection_id: 1, quay: CollectionConfig::EDUCATION_COMMUNITY_PARTNERS_KEY)
        result = CollectionConfig.ed_community_partners(collection_configs)

        expect(result['Education'][0][:logo]).to start_with(CollectionConfig::CDN_HOST)
      end
    end
  end

  describe '.ed_community_show_tabs' do
    it_behaves_like 'it rejects empty configs' do
      let(:method) { :ed_community_show_tabs }
    end

    context 'by default' do
      before(:each) { FactoryGirl.create(:community_tabs_collection_config) }

      it 'returns a boolean value for tabs' do
        configs = CollectionConfig.where(collection_id: 1, quay: CollectionConfig::EDUCATION_COMMUNITY_TABS_KEY)
        result = CollectionConfig.ed_community_show_tabs(configs)
        expect(result).to be_an_instance_of(TrueClass)
      end
    end

    context 'with malformed or missing data' do
      it 'returns nil' do
        result = CollectionConfig.ed_community_show_tabs([])
        expect(result).to be_nil
      end

      it 'logs an error' do
        FactoryGirl.create(:community_sponsor_collection_config_name)
        Rails.logger.should_receive(:error)
        wrong_configs = CollectionConfig.where(collection_id: 1, quay: CollectionConfig::SPONSOR_ACRO_NAME_KEY)
        result = CollectionConfig.ed_community_show_tabs(wrong_configs)

        expect(result).to be_nil
      end
    end
  end

  describe '.ed_community_partner' do
    before(:each) do
      FactoryGirl.create(:community_sponsor_collection_config_name)
      FactoryGirl.create(:community_sponsor_collection_config_page_name)
      FactoryGirl.create(:community_sponsor_collection_config_data)
    end

    let(:result) do
      collection_configs = CollectionConfig.where(collection_id: 1)
      CollectionConfig.ed_community_partner(collection_configs)
    end

    it_behaves_like 'it rejects empty configs' do
      let(:method) { :ed_community_partner }
    end

    it_behaves_like 'it fails with an error' do
      let(:key) { CollectionConfig::SPONSOR_ACRO_NAME_KEY }
      let(:method) { :ed_community_partner }
    end

    it 'returns the acro name and page name' do
      expect(result[:acro_name]).to_not be_nil
      expect(result[:page_name]).to_not be_nil
    end

    it 'sets sponsor data' do
      expect(result[:data]).to_not be_nil
      expect(result[:data]).to be_an_instance_of(Array)
      expect(result[:data]).to have(1).partner
    end

    it 'adds the cdn host to each image' do
      expect(result[:data][0][:logo]).to start_with(CollectionConfig::CDN_HOST)
      expect(result[:data][0][:logo]).to start_with(CollectionConfig::CDN_HOST)
    end
  end

  describe '.choosing_page_links' do
    context 'by default' do
      before(:each) { FactoryGirl.create(:choosing_page_links_configs) }
      it 'returns links' do
        result = CollectionConfig.choosing_page_links(1)
        expect(result).to be_an_instance_of(Array)
        expect(result).to have(4).links
      end
    end

    context 'with malformed or missing data' do
      it 'logs an error' do
        Rails.logger.should_receive(:error)
        result = CollectionConfig.choosing_page_links(1)
      end
      it 'returns nil' do
        result = CollectionConfig.choosing_page_links(1)
        expect(result).to be_nil
      end
    end
  end
end

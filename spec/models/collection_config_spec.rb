require 'spec_helper'

shared_examples "it rejects empty configs" do
  it 'returns nil' do
    result = described_class.send(method, [])
    expect(result).to be_nil
  end
end

shared_examples "it fails with an error" do
  context 'invalid json string' do
    after(:each) { clean_dbs :gs_schooldb }

    it 'returns nil' do
      FactoryGirl.create(:bogus_collection_config, quay: key)
      collection_configs = described_class.where(collection_id: 1, quay: key)
      result = described_class.send(method, collection_configs)

      expect(result).to be_nil
    end

    it 'logs an error' do
      expect(Rails.logger).to receive(:error)
      collection_configs = described_class.where(collection_id: 1, quay: key)
      FactoryGirl.create(:bogus_collection_config, quay: key)

      result = described_class.send(method, collection_configs)
    end
  end
end

shared_examples 'it rejects empty or malformed configs' do
  it_behaves_like 'it rejects empty configs'
  it_behaves_like 'it fails with an error'
end

describe CollectionConfig do
  after(:each) { clean_dbs :gs_schooldb }

  describe '.city_featured_articles' do
    it_behaves_like 'it rejects empty configs' do
      let(:method) { :city_featured_articles }
    end

    it_behaves_like 'it fails with an error' do
      let(:key) { CollectionConfig::FEATURED_ARTICLES_KEY }
      let(:method) { :city_featured_articles }
    end

    context 'valid json string' do
      before(:each) { FactoryGirl.create(:feature_articles_collection_config) }

      it 'parses the articles and returns an array' do
        collection_configs = CollectionConfig.where(collection_id: 1, quay: CollectionConfig::FEATURED_ARTICLES_KEY)
        result = CollectionConfig.city_featured_articles(collection_configs)

        expect(result).to be_an_instance_of(Array)
      end
      it 'adds the asset path to each articleImagePath' do
        collection_configs = CollectionConfig.where(collection_id: 1, quay: CollectionConfig::FEATURED_ARTICLES_KEY)
        result = CollectionConfig.city_featured_articles(collection_configs)

        expect(result.first[:articleImagePath]).to start_with('/assets')
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

        expect(result[:partnerLogos].first[:logoPath]).to start_with('/assets')
        expect(result[:partnerLogos].first[:anchoredLink]).to start_with('education-community')
      end
    end
  end

  describe '.sponsor' do
    it_behaves_like 'it rejects empty configs' do
      let(:method) { :sponsor }
    end

    it_behaves_like 'it fails with an error' do
      let(:key) { CollectionConfig::CITY_HUB_SPONSOR_KEY }
      let(:method) { :sponsor }
    end

    context 'valid json string' do
      it 'parses the sponsors string and returns an array' do
        FactoryGirl.create(:city_hub_sponsor_collection_config)
        collection_configs = CollectionConfig.where(collection_id: 1, quay: CollectionConfig::CITY_HUB_SPONSOR_KEY)
        result = CollectionConfig.sponsor(collection_configs)

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
        FactoryGirl.create(:choose_a_school_collection_configs)
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
      let(:collection_configs) { CollectionConfig.where(collection_id: 1, quay: CollectionConfig::CITY_HUB_IMPORTANT_EVENTS_KEY) }

      it 'parses the important events string and returns a hash' do
        result = CollectionConfig.city_hub_important_events(collection_configs)

        expect(result).to be_an_instance_of(Hash)
      end

      it 'limits to the max number of events' do
        result = CollectionConfig.city_hub_important_events(collection_configs, 1)
        expect(result[:events].length).to eq(1)

        result = CollectionConfig.city_hub_important_events(collection_configs, 2)
        expect(result[:events].length).to eq(2)
      end

      it 'sorts by date' do
        result = CollectionConfig.city_hub_important_events(collection_configs)

        sorted_result = result.clone
        sorted_result[:events].sort_by! { |e| e[:date] }

        expect(result).to eq(sorted_result)
      end

      it 'removes past events' do
        result = CollectionConfig.city_hub_important_events(collection_configs)
        dates = []
        result[:events].each do |event|
          expect(event[:date] >= Date.today).to be_truthy
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
          expect(event[:date] >= Date.today).to be_truthy
        end
      end
    end
  end

  describe '.ed_community_subheading' do
    context 'with missing data' do
      it 'returns an error message' do
        result = CollectionConfig.ed_community_subheading([])
        expect(result).to start_with('Error:')
      end
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

        expect(result['Education'][0][:logo]).to start_with(ENV_GLOBAL['cdn_host'])
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
        expect(Rails.logger).to receive(:error)
        wrong_configs = CollectionConfig.where(collection_id: 1, quay: CollectionConfig::SPONSOR_ACRO_NAME_KEY)
        result = CollectionConfig.ed_community_show_tabs(wrong_configs)

        expect(result).to be_nil
      end
    end
  end

  describe '.partner' do
    before(:each) do
      FactoryGirl.create(:community_sponsor_collection_config_name)
      FactoryGirl.create(:community_sponsor_collection_config_page_name)
      FactoryGirl.create(:community_sponsor_collection_config_data)
    end

    let(:result) do
      collection_configs = CollectionConfig.where(collection_id: 1)
      CollectionConfig.partner(collection_configs)
    end

    it_behaves_like 'it rejects empty configs' do
      before(:each) { clean_dbs :gs_schooldb }
      let(:method) { :partner }
    end

    it_behaves_like 'it fails with an error' do
      before(:each) { clean_dbs :gs_schooldb }
      let(:key) { CollectionConfig::SPONSOR_ACRO_NAME_KEY }
      let(:method) { :partner }
    end

    it 'returns the acro name and page name' do
      expect(result[:acro_name]).to_not be_nil
      expect(result[:page_name]).to_not be_nil
    end

    it 'sets sponsor data' do
      expect(result[:data]).to_not be_nil
      expect(result[:data]).to be_an_instance_of(Array)
      expect(result[:data].size).to eq(1)
    end

    it 'adds the cdn host to each image' do
      expect(result[:data][0][:logo]).to start_with(ENV_GLOBAL['cdn_host'])
      expect(result[:data][0][:logo]).to start_with(ENV_GLOBAL['cdn_host'])
    end
  end

  describe '.choosing_page_links' do
    context 'by default' do
      before(:each) { FactoryGirl.create(:choosing_page_links_configs) }
      let(:configs) { CollectionConfig.all }
      it 'returns links' do
        result = CollectionConfig.choosing_page_links(configs)
        expect(result).to be_an_instance_of(Array)
        expect(result.size).to eq(4)
      end
    end

    context 'with malformed or missing data' do
      let(:configs) { CollectionConfig.all }

      it 'logs an error' do
        expect(Rails.logger).to receive(:error)
        result = CollectionConfig.choosing_page_links(configs)
      end
      it 'returns nil' do
        result = CollectionConfig.choosing_page_links(configs)
        expect(result).to be_nil
      end
    end
  end

  describe '.content_modules' do
    context 'by default' do
      before(:each) { FactoryGirl.create(:state_hub_content_module) }
      let(:configs) { CollectionConfig.all }

      it 'returns parsed content modules' do
        result = CollectionConfig.content_modules(configs)
        expect(result).to be_an_instance_of(Array)
      end
    end

    context 'with missing data' do
      it 'returns nil' do
        result = CollectionConfig.content_modules([])
        expect(result).to be_nil
      end
    end

    context 'with malformed data' do
      it 'logs an error' do
        expect(Rails.logger).to receive(:error)
        configs = FactoryGirl.create(:state_hub_content_module, value: 'foobarbaz')
        result = CollectionConfig.content_modules([configs])
      end
      it 'returns nil' do
        configs = FactoryGirl.create(:state_hub_content_module, value: 'foobarbaz')
        results = CollectionConfig.content_modules([configs])
        expect(results).to be_nil
      end
    end
  end

  describe '.state_featured_articles' do
    context 'by default' do
      it 'parses featured articles' do
        configs = FactoryGirl.create(:state_hub_featured_articles)
        results = CollectionConfig.state_featured_articles([configs])
        expect(results).to be_an_instance_of(Array)
      end

      it 'prepends the assets path to images' do
        configs = FactoryGirl.create(:state_hub_featured_articles)
        results = CollectionConfig.state_featured_articles([configs])
        results.each do |article|
          expect(article[:articleImagePath]).to start_with '/assets'
        end
      end
    end

    context 'with missing data' do
      it 'returns nil' do
        configs = FactoryGirl.create(:community_sponsor_collection_config_data)
        result1 = CollectionConfig.state_featured_articles([])
        result2 = CollectionConfig.state_featured_articles([configs])
        expect(result1).to be_nil
        expect(result2).to be_nil
      end
    end

    context 'with malformed data' do
      it 'logs an error' do
        expect(Rails.logger).to receive(:error)
        configs = FactoryGirl.create(:state_hub_featured_articles, value: 'foobarb]a{z ? ? ? ?')
        CollectionConfig.state_featured_articles([configs])
      end

      it 'returns nil' do
        configs = FactoryGirl.create(:state_hub_featured_articles, value: 'foobarb]a{z ? ? ? ?')
        result = CollectionConfig.state_featured_articles([configs])
        expect(result).to be_nil
      end
    end
  end

  describe '.state_partners' do
    context 'by default' do
      it 'parses state partners' do
        configs = FactoryGirl.create(:state_partners_configs)
        results = CollectionConfig.state_partners([configs])
        expect(results).to be_an_instance_of(Hash)
      end
    end

    context 'with missing data' do
      it 'returns nil' do
        result1 = CollectionConfig.state_partners([])
        result2 = CollectionConfig.state_partners([FactoryGirl.create(:state_hub_featured_articles)])
        expect(result1).to be_nil
        expect(result2).to be_nil
      end
    end

    context 'with malformed data' do
      let(:configs) { FactoryGirl.create(:state_partners_configs, value: 'foobar{? baz do') }
      it 'logs an error' do
        expect(Rails.logger).to receive(:error)
        CollectionConfig.state_partners([configs])
      end
      it 'returns nil' do
        result = CollectionConfig.state_partners([configs])
        expect(result).to be_nil
      end
    end
  end

  describe '.enrollment_subheading' do
    let(:key) { CollectionConfig::ENROLLMENT_SUBHEADING_KEY }

    context 'with missing data' do
      it 'returns an empty object' do
        FactoryGirl.create(:bogus_collection_config, quay: 'foobar_key')
        bogus_configs = CollectionConfig.where(collection_id: 1)
        result = CollectionConfig.enrollment_subheading(bogus_configs)
        expect(result).to eq({})
      end
    end

    context 'with empty data' do
      it 'returns an empty object' do
        FactoryGirl.create(:enrollment_subheading_configs, value: "")
        empty_configs = CollectionConfig.where(collection_id: 1)
        result = CollectionConfig.enrollment_subheading(empty_configs)
        expect(result).to eq({ error: "The enrollment subheading is empty" })
      end
    end

    context 'with malformed data' do
      let(:broken_configs) { [FactoryGirl.create(:bogus_collection_config, quay: key, value: "?? foo bar baz")] }
      it 'logs an error' do
        expect(Rails.logger).to receive(:error)
        CollectionConfig.enrollment_subheading(broken_configs)
      end

      it 'returns an error in the object' do
        result = CollectionConfig.enrollment_subheading(broken_configs)
      end
    end

    context 'by default' do
      it 'returns the enrollment page subheading' do
        FactoryGirl.create(:enrollment_subheading_configs)
        configs = CollectionConfig.where(collection_id: 1)
        result = CollectionConfig.enrollment_subheading(configs)
        expect(result).to be_an_instance_of(Hash)
        expect(result[:content]).to be_an_instance_of(String)
      end
    end
  end

  describe '.key_dates' do
    context 'without data' do
      it 'returns nil values in the results hash' do
        result = CollectionConfig.key_dates([], '')
        expect(result).to be_an_instance_of(Hash)
        expect(result[:public]).to be_nil
        expect(result[:private]).to be_nil
      end
    end

    context 'by default' do
      let(:tab_key) { 'preschool' }
      before(:each) do
        [
          { collection_id: 1, quay: 'keyEnrollmentDates_public_preschool', value: 'some_value' },
          { collection_id: 1, quay: 'keyEnrollmentDates_private_preschool', value: '<br>woot<hr>' }
        ].each { |attrs| CollectionConfig.create(attrs) }
      end
      after(:each) { clean_dbs :gs_schooldb }

      it 'returns a blob of key dates' do
        configs = CollectionConfig.all
        result = CollectionConfig.key_dates(configs, tab_key)
        expect(result).to be_an_instance_of(Hash)
        expect(result).to have_key(:public)
        expect(result).to have_key(:private)
      end
    end
  end

  describe '.enrollment_module' do
    context 'with missing or malformed data' do
      it 'returns nil' do
        results = [ CollectionConfig.enrollment_module([], 'preschool'),
        CollectionConfig.enrollment_module([FactoryGirl.create(:bogus_collection_config)], 'preschool') ]
        results.each do |result|
          expect(result[:public]).to be_nil
          expect(result[:private]).to be_nil
        end
      end
      it 'logs an error' do
        expect(Rails.logger).to receive(:error)
        CollectionConfig.enrollment_module([], 'preschool')
      end
    end

    context 'by default' do
      let(:configs) do
        [
          FactoryGirl.build(:enrollment_module_configs, quay: 'enrollmentPage_private_elementary_module'),
          FactoryGirl.build(:enrollment_module_configs, quay: 'enrollmentPage_public_elementary_module')
        ]
      end

      it 'returns a description and info links' do
        result = CollectionConfig.enrollment_module(configs, 'elementary')
        expect(result).to be_an_instance_of(Hash)

        [:header, :content, :link].each do |key|
          expect(result[:public]).to have_key(key)
          expect(result[:private]).to have_key(key)
        end
      end
    end
  end

  describe '.enrollment_tips' do
    let(:configs) { CollectionConfig.all }

    context 'with missing data' do
      it 'returns nil' do
        result = CollectionConfig.enrollment_tips([], 'preschool')
        expect(result[:public][:content]).to eq([])
        expect(result[:private][:content]).to eq([])
      end
      it 'does not log an error' do
        expect(Rails.logger).to_not receive(:error)
        CollectionConfig.enrollment_tips([], 'preschool')
      end
    end

    context 'malformed data' do
      let(:bogus_configs) { [FactoryGirl.create(:bogus_collection_config)] }

      it 'returns nil' do
        result = CollectionConfig.enrollment_tips(bogus_configs, 'preschool')
        expect(result[:public][:content]).to eq([])
        expect(result[:private][:content]).to eq([])
      end
    end

    context 'a single tip in db' do
      before(:each) do
        FactoryGirl.create(:single_enrollment_tip_config)
      end

      it 'returns an array with a single tip' do
        result = CollectionConfig.enrollment_tips(configs, 'elementary')
        [:public, :private].each { |k| expect(result).to have_key(k) }
      end
    end

    context 'by default' do
      before(:each) do
        FactoryGirl.create(:enrollment_tips_config)
      end

      it 'returns a hash of tips' do
        result = CollectionConfig.enrollment_tips(configs, 'elementary')
        expect(result).to be_an_instance_of(Hash)
        [:public, :private].each { |k| expect(result).to have_key(k) }
      end
    end
  end

  describe '.state_choose_school' do
    context 'with missing or malformed data' do
      let(:bogus_configs) { [FactoryGirl.create(:bogus_collection_config, quay: 'statehubHome_chooseSchool')] }

      it 'returns nil' do
        [
          CollectionConfig.state_choose_school([]),
          CollectionConfig.state_choose_school(bogus_configs)
        ].each { |result| expect(result).to be_nil }
      end
      it 'logs an error' do
        expect(Rails.logger).to receive(:error).twice
        CollectionConfig.state_choose_school([])
        CollectionConfig.state_choose_school(bogus_configs)
      end
    end

    context 'by default' do
      before(:each) do
        FactoryGirl.create(:state_choose_school_config)
      end
      let(:configs) { CollectionConfig.all }

      it 'parses and returns the state choosing schools module' do
        result = CollectionConfig.state_choose_school(configs)
        expect(result).to be_an_instance_of(Hash)
        [:link, :heading, :content].each do |key|
          expect(result).to have_key(key)
        end
      end
    end
  end

  describe '.key_dates' do
    let(:configs) { CollectionConfig.all }
    let(:nil_result) { { public: nil, private: nil } }

    context 'with missing data' do
      it 'returns nil' do
        result = CollectionConfig.key_dates([], 'preschool')
        expect(result).to eq(nil_result)
      end
      it 'does not log an error' do
        expect(Rails.logger).to_not receive(:error)
        result = CollectionConfig.key_dates([], 'preschool')
      end
    end

    context 'with malformed data' do
      before(:each) { FactoryGirl.create(:bogus_collection_config, quay: 'keyEnrollmentDates_private_preschool') }

      it 'returns nil' do
        result = CollectionConfig.key_dates(configs, 'preschool')
        expect(result).to eq(nil_result)
      end
      it 'logs an error' do
        expect(Rails.logger).to receive(:error)
        result = CollectionConfig.key_dates(configs, 'preschool')
      end
    end

    context 'by default' do
      before(:each) { FactoryGirl.create(:key_dates_config) }

      it 'returns parsed key dates' do
        result = CollectionConfig.key_dates(configs, 'preschool')
        expect(result).to be_an_instance_of(Hash)
        [:public, :private].each do |type|
          expect(result[type]).to be_an_instance_of(String)
        end
      end
    end
  end

  describe '.browse_links' do
    it_behaves_like 'it rejects empty or malformed configs' do
      let(:key) { CollectionConfig::CITY_HUB_BROWSE_LINKS_KEY }
      let(:method) { :browse_links }
    end

    context 'by default' do
      before { FactoryGirl.create(:browse_links_config) }
      let(:configs) { CollectionConfig.where(collection_id: 1) }
      let(:result) { CollectionConfig.browse_links(configs) }

      it 'parses browse links' do
        expect(result).to be_an_instance_of(Array)
        expect(result.size).to eq(7)
      end
    end
  end

  describe '.programs_heading' do
    it_behaves_like 'it rejects empty configs' do
      let(:method) { :programs_heading }
    end

    context 'by default' do
      let(:configs) { [FactoryGirl.build(:programs_heading_config)] }
      let(:heading) { CollectionConfig.programs_heading(configs) }

      it 'returns the programs heading' do
        expect(heading).to start_with 'What makes a great after'
      end
    end
  end

  describe '.programs_intro' do
    it_behaves_like 'it rejects empty or malformed configs' do
      let(:key) { CollectionConfig::PROGRAMS_INTRO_KEY }
      let(:method) { :programs_intro }
    end

    context 'by default' do
      let(:configs) { [FactoryGirl.build(:programs_intro_config)] }
      let(:result) { CollectionConfig.programs_intro(configs) }

      it 'returns the intro section html blob' do
        expect(result[:content]).to start_with 'Quality after-school and summer learning'
      end
    end
  end

  describe '.programs_sponsor' do
    it_behaves_like 'it rejects empty or malformed configs' do
      let(:method) { :programs_sponsor }
      let(:key) { CollectionConfig::PROGRAMS_SPONSOR_KEY }
    end

    context 'by default' do
      let(:configs) { [FactoryGirl.build(:programs_sponsor_config)] }
      let(:result) { CollectionConfig.programs_sponsor(configs) }

      it 'parses the programs page sponsor' do
        expect(result[:logo]).to eq('hubs/after_school_programs.png')
      end
    end
  end

  describe '.programs_partners' do
    it_behaves_like 'it rejects empty or malformed configs' do
      let(:method) { :programs_partners }
      let(:key) { CollectionConfig::PROGRAMS_PARTNERS_KEY }
    end

    context 'by default' do
      it 'parses programs page partners'
    end
  end

  describe '.programs_articles' do
    let(:method) { :programs_articles }
    let(:key) { CollectionConfig::PROGRAMS_ARTICLES_KEY }

    it_behaves_like 'it rejects empty configs'
    it_behaves_like 'it fails with an error'

    context 'by default' do
      let(:configs) { [FactoryGirl.build(:programs_articles_config)] }
      let(:result) { CollectionConfig.programs_articles(configs) }

      it 'parses programs page articles' do
        expect(result).to have_key :sectionHeading
        expect(result).to have_key :articles
      end
    end
  end
end

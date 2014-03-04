require 'spec_helper'

articles_value = "{ articles :[ { heading:'How to spot a world-class education', content:'In an exclusive adaptation from her new book, \"The Smartest Kids in the World,\" Amanda Ripley encapsulates her three years studying high-performing schools around the globe into a few powerful guidelines.', articlepath:'/school-choice/7624-amanda-ripley-how-to-spot-world-class-education.gs', articleImagePath:'/res/img/cityHubs/1_Article_1.png', newwindow:'false' } ,{ heading:'Education Detroit', content:'A new magazine devoted to helping Detroit parents/guardians give kids an academic edge and find standout school options', articlepath:'http://www.metroparent.com/Metro-Parent/Education-Detroit/', articleImagePath:'/res/img/cityHubs/1_Article_2.png', newwindow:'true' } , { heading:'Excellent News!', content:'Videos on what\\'s working in Detroit schools and information about the choices available for your children', articlepath:'http://vimeo.com/channels/590307', articleImagePath:'/res/img/cityHubs/1_Article_3.png', newwindow:'true' } ] } "
partners_value = "{ heading:'Detroit Education Community', partnerLogos:[ " \
 "{ logoPath:'/res/img/cityHubs/1_Partner_0.png', partnerName:'Black Family Development, Inc.', anchoredLink:'?tab=Community' }" \
  ", { logoPath:'/res/img/cityHubs/1_Partner_1.png', partnerName:'Cornerstone Charters', anchoredLink:'?tab=Education' } , { logoPath:'/res/img/cityHubs/1_Partner_2.png', partnerName:'Detroit Edison Public School Academy', anchoredLink:'?tab=Education' } , { logoPath:'/res/img/cityHubs/1_Partner_3.png', partnerName:'Detroit Parent Network', anchoredLink:'?tab=Community' } , { logoPath:'/res/img/cityHubs/1_Partner_4.png', partnerName:'Detroit Public Schools', anchoredLink:'?tab=Education' },"\
  "{ logoPath:'/res/img/cityHubs/1_Partner_5.png', partnerName:'Detroit Public Television', anchoredLink:'?tab=Community' }," \
  "{ logoPath:'/res/img/cityHubs/1_Partner_6.png', partnerName:'Detroit Regional Chamber', anchoredLink:'?tab=Community' }," \
  "{ logoPath:'/res/img/cityHubs/1_Partner_7.png', partnerName:'Education Achievement Authority', anchoredLink:'?tab=Education' }," \
  "{ logoPath:'/res/img/cityHubs/1_Partner_8.png', partnerName:'Kresge Foundation', anchoredLink:'?tab=Funders' }," \
  "{ logoPath:'/res/img/cityHubs/1_Partner_9.png', partnerName:'The Skillman Foundation', anchoredLink:'?tab=Funders' }," \
  "{ logoPath:'/res/img/cityHubs/1_Partner_10.png', partnerName:'United Way for Southeastern Michigan', anchoredLink:'?tab=Community' }]  }"
sponsor_value = "{ sponsor:{  name:'Detroit Excellent Schools', text:'In partnership with',path:'/res/img/cityHubs/1_sponsor.png'} }"
choose_school_value = "{    heading:'Finding a Great School in Detroit',    content:'We&#39;re here to help you explore your options and find the right school for your child. To get started with the school research process, check out the resources below to learn more about how to choose a school and how enrollment works in Detroit.',    link:[        {            name:'Five steps to choosing a school &#187;',            path:'choosing-schools',            newWindow: ''        },        {            name:' education community &#187;',            path:'education-community',            newWindow:''        },        {            name:'How enrollment works in Detroit &#187;',            path:'enrollment',            newWindow:''        }    ]}"
announcement_value = "{content:'foobar a ton of content',      link: { name:'Learn More',      path:'http://www.metroparent.com/Metro-Parent/Education-Detroit/', newWindow:'true' } }"
important_events_value = "{ events: [   {     date: '02-17-2014',     description: 'DPS: Mid-Winter Break Starts',    url: 'http://detroitk12.org/calendars/academic/'  },  {     date: '03-19-2014',     description:'DPS: Schools Closed',    url: 'http://detroitk12.org/calendars/academic/'  },  {     date: '04-12-2014',     description: 'Loyola High School Open House',     url: 'http://www.aod.org/schools/choose-catholic-high-schools/high-school-open-houses-and-testing/'   } ] } "

shared_examples "it rejects empty configs" do
  it 'returns nil' do
    result = described_class.send(method, [])
    expect(result).to be_nil
  end
end

shared_examples "it fails with an error" do
  context 'invalid json string' do
    it 'returns nil' do
      described_class.create(collection_id: 1, quay: key, value: 'foo bar')
      collection_configs = described_class.where(collection_id: 1, quay: key)
      result = described_class.send(method, collection_configs)

      expect(result).to be_nil
    end

    it 'logs an error' do
      Rails.logger.should_receive(:error)

      described_class.create(collection_id: 1, quay: key, value: 'foo bar')
      collection_configs = described_class.where(collection_id: 1, quay: key)
      result = described_class.send(method, collection_configs)
    end
  end
end

describe CollectionConfig do
  after(:each) do
    CollectionConfig.destroy_all
  end
  describe '.featured_articles' do
    it_behaves_like 'it rejects empty configs' do
      let(:method) { :featured_articles }
    end

    it_behaves_like 'it fails with an error' do
      let(:key) { CollectionConfig::FEATURED_ARTICLES_KEY }
      let(:method) { :featured_articles }
    end

    context 'valid json string' do
      it 'parses the articles and returns an array' do
        CollectionConfig.create(collection_id: 1, quay: CollectionConfig::FEATURED_ARTICLES_KEY, value: articles_value)
        collection_configs = CollectionConfig.where(collection_id: 1, quay: CollectionConfig::FEATURED_ARTICLES_KEY)
        result = CollectionConfig.featured_articles(collection_configs)

        expect(result).to be_an_instance_of(Array)
      end
      it 'adds the cdn host to each articleImagePath' do
        CollectionConfig.create(collection_id: 1, quay: CollectionConfig::FEATURED_ARTICLES_KEY, value: articles_value)
        collection_configs = CollectionConfig.where(collection_id: 1, quay: CollectionConfig::FEATURED_ARTICLES_KEY)
        result = CollectionConfig.featured_articles(collection_configs)
        cdn_match = result.first[:articleImagePath].start_with?('http://www.gscdn.org')

        expect(cdn_match).to be_true
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
      it 'parses the partners string and returns a hash' do
        CollectionConfig.create(collection_id: 1, quay: CollectionConfig::CITY_HUB_PARTNERS_KEY, value: partners_value)
        collection_configs = CollectionConfig.where(collection_id: 1, quay: CollectionConfig::CITY_HUB_PARTNERS_KEY)
        result = CollectionConfig.city_hub_partners(collection_configs)

        expect(result).to be_an_instance_of(Hash)
      end

      it 'sets the link and path for partners' do
        CollectionConfig.create(collection_id: 1, quay: CollectionConfig::CITY_HUB_PARTNERS_KEY, value: partners_value)
        collection_configs = CollectionConfig.where(collection_id: 1, quay: CollectionConfig::CITY_HUB_PARTNERS_KEY)
        result = CollectionConfig.city_hub_partners(collection_configs)

        expect(result[:partnerLogos].first[:logoPath].start_with?('http://www.gscdn.org')).to be_true
        expect(result[:partnerLogos].first[:anchoredLink].start_with?('education-community')).to be_true
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
        CollectionConfig.create(collection_id: 1, quay: CollectionConfig::CITY_HUB_SPONSOR_KEY, value: sponsor_value)
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
        CollectionConfig.create(collection_id: 1, quay: CollectionConfig::CITY_HUB_CHOOSE_A_SCHOOL_KEY, value: choose_school_value)
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
        CollectionConfig.create(collection_id: 1, quay: CollectionConfig::CITY_HUB_ANNOUNCEMENT_KEY, value: announcement_value)
        collection_configs = CollectionConfig.where(collection_id: 1, quay: CollectionConfig::CITY_HUB_ANNOUNCEMENT_KEY)
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
      it 'parses the important events string and returns a hash' do
        CollectionConfig.create(collection_id: 1, quay: CollectionConfig::CITY_HUB_IMPORTANT_EVENTS_KEY, value: important_events_value)
        collection_configs = CollectionConfig.where(collection_id: 1, quay: CollectionConfig::CITY_HUB_IMPORTANT_EVENTS_KEY)
        result = CollectionConfig.city_hub_important_events(collection_configs)

        expect(result).to be_an_instance_of(Hash)
      end

      it 'limits to the max number of events' do
        CollectionConfig.create(collection_id: 1, quay: CollectionConfig::CITY_HUB_IMPORTANT_EVENTS_KEY, value: important_events_value)
        collection_configs = CollectionConfig.where(collection_id: 1, quay: CollectionConfig::CITY_HUB_IMPORTANT_EVENTS_KEY)
        result = CollectionConfig.city_hub_important_events(collection_configs, 1)
        expect(result[:events].length).to eq(1)

        result = CollectionConfig.city_hub_important_events(collection_configs, 2)
        expect(result[:events].length).to eq(2)
      end

      it 'sorts by date' do
        CollectionConfig.create(collection_id: 1, quay: CollectionConfig::CITY_HUB_IMPORTANT_EVENTS_KEY, value: important_events_value)
        collection_configs = CollectionConfig.where(collection_id: 1, quay: CollectionConfig::CITY_HUB_IMPORTANT_EVENTS_KEY)
        result = CollectionConfig.city_hub_important_events(collection_configs)

        sorted_result = result.clone
        sorted_result[:events].sort_by! { |e| e[:date] }

        expect(result).to eq(sorted_result)
      end

      it 'removes past events' do
        CollectionConfig.create(collection_id: 1, quay: CollectionConfig::CITY_HUB_IMPORTANT_EVENTS_KEY, value: important_events_value)
        collection_configs = CollectionConfig.where(collection_id: 1, quay: CollectionConfig::CITY_HUB_IMPORTANT_EVENTS_KEY)
        result = CollectionConfig.city_hub_important_events(collection_configs)
        dates = []
        result[:events].each do |event|
          expect(event[:date] >= Date.today).to be_true
        end
      end
    end
  end
end

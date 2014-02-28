require 'spec_helper'

articles_value = "{ articles :[ { heading:'How to spot a world-class education', content:'In an exclusive adaptation from her new book, \"The Smartest Kids in the World,\" Amanda Ripley encapsulates her three years studying high-performing schools around the globe into a few powerful guidelines.', articlepath:'/school-choice/7624-amanda-ripley-how-to-spot-world-class-education.gs', articleImagePath:'/res/img/cityHubs/1_Article_1.png', newwindow:'false' } ,{ heading:'Education Detroit', content:'A new magazine devoted to helping Detroit parents/guardians give kids an academic edge and find standout school options', articlepath:'http://www.metroparent.com/Metro-Parent/Education-Detroit/', articleImagePath:'/res/img/cityHubs/1_Article_2.png', newwindow:'true' } , { heading:'Excellent News!', content:'Videos on what\\'s working in Detroit schools and information about the choices available for your children', articlepath:'http://vimeo.com/channels/590307', articleImagePath:'/res/img/cityHubs/1_Article_3.png', newwindow:'true' } ] } "

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

    context 'valid json string' do
      it 'parses the articles and returns an array' do
        collection_configs = CollectionConfig.create(collection_id: 1, quay: 'hubHome_cityArticle', value: articles_value)
        CollectionConfig.featured_articles(collection_configs)

        expect(result).to be_an_instance_of(Array)
      end
      it 'adds the cdn host to each articleImagePath' do
        collection_configs = CollectionConfig.create(collection_id: 1, quay: 'hubHome_cityArticle', value: articles_value)
        result = CollectionConfig.featured_articles(collection_configs)
        cdn_match = result['articles'].first[articleImagePath].start_with?('http://www.gscdn.org')

        expect(cdn_match).to be_true
      end
    end

    context 'invalid json string' do
      it 'returns nil' do
        collection_configs = CollectionConfig.create(collection_id: 1, quay: 'hubHome_cityArticle', value: 'foo bar')
        result = CollectionConfig.featured_articles(collection_configs)

        expect(result).to be_nil
      end

      it 'logs an error' do
        collection_configs = CollectionConfig.create(collection_id: 1, quay: 'hubHome_cityArticle', value: 'foo bar')
        result = CollectionConfig.featured_articles(collection_configs)

        Rails.logger.should_receive(:error)
      end
    end
  end

  describe '.city_hub_partners' do
    it_behaves_like 'it rejects empty configs' do
      let(:method) { :city_hub_partners }
    end

    context 'valid json string' do
      it 'parses the partners string and returns a hash' do
        collection_configs = CollectionConfig.create(collection_id: 1, quay: 'hubHome_cityArticle', value: articles_value)
        result = CollectionConfig.city_hub_partners(collection_configs)
      end
    end

    context 'valid json string' do
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

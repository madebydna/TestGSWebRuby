require 'spec_helper'
require 'controllers/contexts/ad_shared_contexts'
require 'controllers/examples/ad_shared_examples'

describe HomeController do

  describe '#index_page_publications' do
    let(:publications) do
      {
        1 => FactoryGirl.build(:publication, id: 1),
        23 => FactoryGirl.build(:publication, id: 23),
        45 => FactoryGirl.build(:publication, id: 45)
      }
    end
    before do
      allow(Publication).to receive(:find_by_ids).and_return(publications)
      allow(controller).to receive(:format_publications)
    end
    it 'should search for publications by id' do
      expect(Publication).to receive(:find_by_ids).with(1, 23, 45)
      controller.index_page_publications
    end
    it 'should call format_publications and pass in publications as parameters' do
      expect(controller).to receive(:format_publications).with(publications)
      controller.index_page_publications
    end
  end

  describe '#format_publications' do
    let(:publication1) { FactoryGirl.build(:publication, id: 1) }
    let(:publication23) { FactoryGirl.build(:publication, id: 23) }
    let(:publication45) { FactoryGirl.build(:publication, id: 45) }
    let(:publications) do
      {
          1 => publication1,
          23 => publication23,
          45 => publication45
      }
    end

    before do
      allow_any_instance_of(Publication).to receive(:create_attributes_for)
    end
    it 'should call create_attributes_for each publication' do
      expect(publication1).to receive(:create_attributes_for).exactly(1).times
      expect(publication23).to receive(:create_attributes_for).exactly(1).times
      expect(publication45).to receive(:create_attributes_for).exactly(1).times
      controller.format_publications(publications)
    end
    it 'should call create_attributes_for and pass in title, body, and author parameters' do
      expect(publication1).to receive(:create_attributes_for).with('title', 'body', 'author')
      expect(publication23).to receive(:create_attributes_for).with('title', 'body', 'author')
      expect(publication45).to receive(:create_attributes_for).with('title', 'body', 'author')
      controller.format_publications(publications)
    end
    it 'should return a hash' do
      expect(controller.format_publications(publications)).to be_a Hash
    end
    it 'should return a hash of publications' do
      expect(controller.format_publications(publications)[1]).to be_a Publication
    end
  end

  describe '#ad_setTargeting_through_gon' do
    subject do
      get :show
      controller.gon.get_variable('ad_set_targeting')
    end

    include_example 'sets at least one google ad targeting attribute'
    include_example 'sets the base google ad targeting attributes for all pages'
    include_example 'sets specific google ad targeting attributes', %w[editorial]
  end

end



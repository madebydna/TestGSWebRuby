require 'spec_helper'

describe Publication do

  describe '.find_by_ids' do
    subject(:publication) { FactoryGirl.build(:publication) }
    before { Publication.stub(:find).and_return(publication) }
    it 'should return a hash' do
      expect(Publication.find_by_ids(1)).to be_an_instance_of Hash
    end
    it 'should return a hash with a the id as the key' do
      expect(Publication.find_by_ids(1).keys.first).to equal publication.id
    end
    context 'when the id exists in database' do
      it 'should return the publication as the value of the key' do
        expect(Publication.find_by_ids(1)[1]).to equal publication
      end
    end
    context 'when the id does not exist in database' do
      it 'should return nil as the value of the key' do
        expect(Publication.find_by_ids(1)[2]).to be_nil
      end
    end
  end

  describe '#create_attributes_for' do
  	subject(:publication) { FactoryGirl.build(:publication) }
    context 'when multiple attributes need to be created' do
      it 'should call create attribute multiple times' do
        expect(publication).to receive(:create_attribute).exactly(3).times
        publication.create_attributes_for 'title', 'body', 'id'
      end
      it 'should create multiple attributes' do
        publication.create_attributes_for 'title', 'body', 'id'
        expect(publication).to respond_to(:title)
        expect(publication).to respond_to(:body)
        expect(publication).to respond_to(:id)
      end
    end
    context 'when a single attribute needs to be created' do
      it 'should call create attribute one time' do
        expect(publication).to receive(:create_attribute).exactly(1).times
        publication.create_attributes_for 'title'
      end
      it 'should create one attributes' do
        publication.create_attributes_for 'title'
        expect(publication).to respond_to(:title)
      end
    end
  end
end

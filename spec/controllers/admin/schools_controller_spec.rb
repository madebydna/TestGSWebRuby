require 'spec_helper'

describe Admin::SchoolsController do

  describe '#school_reviews' do
    let(:school) { FactoryGirl.build(:school) }
    before(:each) do
      controller.instance_variable_set(:@school, school)
    end

    it 'it should sort reviews by posted date in descending order' do
      relation = double('relation')
      SchoolRating.stub(:where).and_return relation
      expect(relation).to receive(:order).with('posted desc')
      controller.school_reviews
    end
  end
  
end
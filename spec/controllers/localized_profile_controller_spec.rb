require 'spec_helper'

describe LocalizedProfileController do

  let(:school) { FactoryGirl.build(:school) }
  let(:page) { FactoryGirl.build(:page) }
  let(:page_config) { double(PageConfig) }

  shared_examples_for 'a configurable profile page' do |action|
    before do
      controller.stub(:find_school).and_return(school)
      PageConfig.stub(:new).and_return(page_config)
    end

    it 'should set a PageConfig object' do
      get action, state: 'ca', schoolId: 1
      expect(assigns[:page_config]).to be_present
    end

    it 'should look up the correct school' do
      get action, state: 'ca', schoolId: 1
      expect(assigns[:school]).to eq(school)
    end

    it 'should set data needed for header' do
      get action, state: 'ca', schoolId: 1
      expect(assigns[:header_metadata]).to be_present
      expect(assigns[:school_reviews_global]).to be_present
    end

    it 'should 404 with non-existent school' do
      controller.stub(:find_school).and_return(nil)
      get action, state: 'ca', schoolId: 1
      expect(response.code).to eq('404')
    end

    it 'should look for a signed in user' do
      pending
      expect(User).to receive(:find).and_return(nil)
      request.cookies['MEMID'] = 123
      get 'overview'
    end

    it 'should convert a full state name to a state abbreviation' do
      get action, state: 'california', schoolId: 1
      expect(assigns[:state]).to eq('ca')
    end

    it 'should 404 with non-existent state' do
      get action, state: 'garbage', schoolId: 1
      expect(response.code).to eq('404')
    end

    it 'should 404 with garbage state' do
      get action, state: 0, schoolId: 1
      expect(response.code).to eq('404')
    end

    it 'should 404 with no state' do
      get action, schoolId: 1
      expect(response.code).to eq('404')
    end

    it 'should 404 with garbage school' do
      get action, state: 'ca', schoolId: 'garbage'
      expect(response.code).to eq('404')
    end
  end

  describe 'GET overview' do
    it_behaves_like 'a configurable profile page', 'overview'
  end

  describe 'GET quality' do
    it_behaves_like 'a configurable profile page', 'quality'
  end

  describe 'GET details' do
    it_behaves_like 'a configurable profile page', 'details'
  end

  describe 'GET reviews' do
    before do
      controller.stub(:find_school).and_return(school)
      PageConfig.stub(:new).and_return(page_config)
    end

    it 'should set the list of reviews' do
      reviews = [ mock_model(SchoolRating) ]
      expect(school).to receive(:reviews_filter).and_return(reviews)
      get 'reviews', state: 'ca', schoolId: 1
      expect(assigns[:school_reviews]).to eq(reviews)
    end

    it 'should look up the correct school' do
      get 'reviews', state: 'ca', schoolId: 1
      expect(assigns[:school]).to eq(school)
    end

    it 'should set data needed for header' do
      get 'reviews', state: 'ca', schoolId: 1
      expect(assigns[:header_metadata]).to be_present
      expect(assigns[:school_reviews_global]).to be_present
    end
  end

end
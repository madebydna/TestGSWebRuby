require 'spec_helper'

describe LocalizedProfileController do

  let(:school) { FactoryGirl.build(:school) }

  describe 'GET overview' do

    it 'should look up the correct school' do
      School.should_receive(:find).and_return(school)
      get 'overview'
    end

    it 'should look for a signed in user' do
      User.should_receive(:find).and_return(nil)
      request.cookies['MEMID'] = 123
      get 'overview'
    end

    it 'should look up the Page object configuration' do
      Page.should_receive(:where).and_return(double('page').as_null_object)
      get 'overview'
    end

    it 'should initialize the header' do
      controller.should_receive(:initHeader)
      get 'overview'
    end

  end

end
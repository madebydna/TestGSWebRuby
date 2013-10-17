require 'spec_helper'

describe LocalizedProfileController do

  let(:school) { FactoryGirl.build(:school) }
  let(:page) { FactoryGirl.build(:page) }

  describe 'GET overview' do

    before do
      controller.stub(:find_school) do
        controller.instance_variable_set(:@school, school)
      end
      controller.stub(:page) do
        controller.instance_variable_set(:@page, page)
      end
    end

    it 'should look up the correct school' do
      controller.unstub(:find_school)
      expect(School).to receive(:find).with(99).and_return(school)
      get 'overview', schoolId: 99
    end

    it 'should look for a signed in user' do
      expect(User).to receive(:find).and_return(nil)
      request.cookies['MEMID'] = 123
      get 'overview'
    end

    it 'should look up the Page object configuration' do
      controller.unstub(:page)
      expect(Page).to receive(:where).with(name: 'Overview').and_return(double('page').as_null_object)
      get 'overview'
    end

    it 'should initialize the header' do
      expect(controller).to receive(:initHeader)
      get 'overview'
    end

  end

end
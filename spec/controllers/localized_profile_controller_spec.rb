require 'spec_helper'

describe LocalizedProfileController do

  let(:school) { FactoryGirl.build(:school) }
  let(:page) { FactoryGirl.build(:page) }

  describe 'GET overview' do

    before do
      controller.stub(:find_school).and_return(school)
      controller.stub(:require_state).and_return('ca')
      controller.stub(:page) do
        controller.instance_variable_set(:@page, page)
      end
    end

    it 'should look up the correct school' do
      controller.unstub(:find_school)
      expect(School).to receive(:find).with(99).and_return(school)
      get 'overview', schoolId: 99, state: 'ca'
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

    it 'should convert a full state name to a state abbreviation' do
      controller.unstub(:require_state)
      get 'overview', state: 'california'
      expect(assigns[:state]).to eq('ca')
    end

    it 'should 404 with non-existent state' do
      controller.unstub(:require_state)
      get 'overview', state: 'garbage'
      expect(response.code).to eq('404')
    end

    it 'should 404 with garbage state' do
      controller.unstub(:require_state)
      get 'overview', state: 0
      expect(response.code).to eq('404')
    end

    it 'should 404 with no state' do
      controller.unstub(:require_state)
      get 'overview'
      expect(response.code).to eq('404')
    end

    it 'should 404 with non-existent school' do
      controller.unstub(:find_school)
      get 'overview', schoolId: 0, state: 'ca'
      expect(response.code).to eq('404')
    end

    it 'should 404 with garbage school' do
      controller.unstub(:find_school)
      get 'overview', schoolId: 'garbage', state: 'ca'
      expect(response.code).to eq('404')
    end

  end

end
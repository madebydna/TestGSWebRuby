require 'spec_helper'

describe CitiesController do
  before(:each) do
    HubCityMapping.destroy_all
    FactoryGirl.create(:hub_city_mapping)
  end

  shared_examples_for 'a default cities controller action' do |action|
    context 'without a hub city mapping' do
      it 'renders an error page' do
        get action, state: 'michigan', city: 'foobarnotacity'
        expect(response).to render_template('error/page_not_found')
      end
    end

    it 'sets canonical tags' do
      get action, state: 'michigan', city: 'detroit'
      expect(assigns[:canonical_url]).to_not be_nil
    end
  end

  describe 'GET show' do
    it_behaves_like 'a default cities controller action', :show
  end

  describe 'GET events' do
    it_behaves_like 'a default cities controller action', :events
  end

  describe 'GET partner' do
    it_behaves_like 'a default cities controller action', :partner
  end

  describe 'GET community' do
    it_behaves_like 'a default cities controller action', :community
  end

  describe 'GET choosing_schools' do
    it_behaves_like 'a default cities controller action', :choosing_schools
  end
end

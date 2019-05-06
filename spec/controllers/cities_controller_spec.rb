require 'spec_helper'

describe CitiesController do
  before { stub_request(:post, /\/solr\/main\/select/).to_return(status: 200, body: "{}", headers: {}) }
  after(:each) { clean_dbs :gs_schooldb }

  let(:url_state) { 'california' }
  let(:state) { 'CA' }
  let(:url_city) { gs_legacy_url_city_encode('San Francisco').downcase }
  let(:city) { 'San Francisco' }
  let(:city_record) { FactoryGirl.build(:city, name: 'San Francisco') }

  before do
    allow(controller).to receive(:state).and_return(state)
    allow(controller).to receive(:city).and_return(city)
    allow(controller).to receive(:city_record).and_return(city_record)
  end

  shared_examples_for 'a cities controller action' do |action|
    context 'where no active city is found' do
      let(:city_record) { nil }
      it 'redirects to state home' do
        get action, state: url_state, city: gs_legacy_url_city_encode('foobarnotacity')
        expect(response).to redirect_to(state_url(url_state, host: 'test.host'))
      end
    end

    context 'a city' do
      it 'sets canonical tags' do
        allow(controller).to receive(:top_rated_schools).and_return([])
        get action, state: url_state, city: url_city
        expect(controller.send(:meta_tags)['canonical']).to be_present
      end

      it 'sets city in data_layer' do
        expect(controller.send(:page_analytics_data)).to include('City')
      end

      it 'sets state in data_layer' do
        expect(controller.send(:page_analytics_data)).to include('State')
      end

      it 'sets page_name in data_layer' do
        expect(controller.send(:page_analytics_data)).to include('page_name')
      end
    end
  end

  describe 'GET show' do
    it_behaves_like 'a cities controller action', :show
  end
end

require 'spec_helper'
require 'controllers/examples/rating_methodology_selector_shared_examples'

describe CitiesController do
  before { stub_request(:post, /\/solr\/main\/select/).to_return(status: 200, body: "{}", headers: {}) }
  after(:each) { clean_dbs :gs_schooldb }

  let(:url_state) { 'california' }
  let(:state) { 'CA' }
  let(:url_city) { gs_legacy_url_city_encode('San Francisco').downcase }
  let(:city) { 'San Francisco' }
  let(:city_record) { FactoryBot.build(:city, name: 'San Francisco') }

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
        allow(controller).to receive(:has_csa_schools?).and_return(false)
        get action, state: url_state, city: url_city
        expect(controller.send(:meta_tags)['canonical']).to be_present
      end

      context 'noindex meta tag' do
        before do
          allow(controller).to receive(:cache_school_levels).and_return(school_levels_cache)
          get action, state: url_state, city: url_city
        end

        subject { controller.send(:meta_tags)['noindex'] }

        context 'when cache is missing' do
          let(:school_levels_cache) { nil }

          it { is_expected.to be_truthy }
        end

        context 'when 0 schools' do
          let(:school_levels_cache) { {'all' => [{'city_value' => 0}] } }

          it { is_expected.to be_truthy }
        end

        context 'when 2 schools' do
          let(:school_levels_cache) { {'all' => [{'city_value' => 2}] } }

          it { is_expected.to be_truthy }
        end

        context 'when 3 schools' do
          let(:school_levels_cache) { {'all' => [{'city_value' => 3}] } }

          it { is_expected.to be_falsey }
        end
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

      context 'without CSA schools' do
        it 'sets gs_badge in data_layer' do
          expect(controller.send(:page_analytics_data)).to include('gs_badge')
        end
      end

      context 'with CSA schools' do
        before { allow(controller).to receive(:has_csa_schools?).and_return(true) }

        it 'does not set gs_badge in data_layer' do
          expect(controller.send(:page_analytics_data)).to_not include('gs_badge')
        end
      end
    end
  end

  describe 'GET show' do
    it_behaves_like 'a cities controller action', :show
  end

  include_examples '#ratings_link', { city: 'Oakland' }
end

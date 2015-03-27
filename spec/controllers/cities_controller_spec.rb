require 'spec_helper'
require 'controllers/contexts/ad_shared_contexts'
require 'controllers/examples/ad_shared_examples'

describe CitiesController do
  before(:each) { FactoryGirl.create(:hub_city_mapping) }
  after(:each) { clean_dbs :gs_schooldb, :surveys }

  shared_examples_for 'a default cities controller action' do |action|
    context 'without a hub city mapping' do
      it 'renders an error page' do
        get action, state: 'michigan', city: gs_legacy_url_city_encode('foobarnotacity')
        expect(response).to render_template('error/page_not_found')
      end
    end

    it 'sets canonical tags' do
      get action, state: 'michigan', city: gs_legacy_url_city_encode('detroit')
      expect(assigns[:canonical_url]).to_not be_nil
    end
  end

  describe 'GET show' do
    context 'without a hub city mapping' do
      it 'renders an error page' do
        get :show, state: 'michigan', city: gs_legacy_url_city_encode('foobarnotacity')
        expect(response).to redirect_to(state_url('michigan'))
      end
    end

    it 'sets canonical tags' do
      get :show, state: 'michigan', city: gs_legacy_url_city_encode('detroit')
      expect(assigns[:canonical_url]).to_not be_nil
    end
  end

  describe '#ad_setTargeting_through_gon' do
    subject do
      get :show, state: 'michigan', city: gs_legacy_url_city_encode('detroit')
      controller.gon.get_variable('ad_set_targeting')
    end

    with_shared_context('when ads are enabled') do
      include_examples 'sets at least one google ad targeting attribute'
      include_examples 'sets the base google ad targeting attributes for all pages'
      include_examples 'sets specific google ad targeting attributes', %w[City State]
    end

    with_shared_context('when ads are not enabled') do
      include_example 'does not set any google ad targeting attributes'
    end
  end

  describe 'Get city_home' do
    before { clean_models :us_geo, City }
    after { clean_models :us_geo, City }
    it 'should redirect to the state page if a deactivated city is requested' do
      city = FactoryGirl.create(:city, active: 0)
      allow_any_instance_of(CitiesController).to receive(:set_hub).and_return(nil)
      state_name = States.state_name(city.state)

      get :show, state: state_name, city: gs_legacy_url_city_encode(city.name)
      expect(response).to redirect_to(state_url(state_name))
    end
  end

  describe 'GET events' do
    it_behaves_like 'a default cities controller action', :events
  end

  describe 'GET partner' do
    before(:each) do
      FactoryGirl.create(:community_sponsor_collection_config_page_name)
      FactoryGirl.create(:community_sponsor_collection_config_data)
      FactoryGirl.create(:sponsor_page_acro_name_configs)
    end

    it_behaves_like 'a default cities controller action', :partner
  end

  describe 'GET community' do
    it_behaves_like 'a default cities controller action', :community
  end

  describe 'GET choosing_schools' do
    it_behaves_like 'a default cities controller action', :choosing_schools
  end

  describe 'GET enrollment' do
    it_behaves_like 'a default cities controller action', :enrollment
  end

  describe 'GET programs' do
    it_behaves_like 'a default cities controller action', :programs
  end
end

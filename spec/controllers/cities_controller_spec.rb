require 'spec_helper'
require 'controllers/contexts/ad_shared_contexts'
require 'controllers/examples/ad_shared_examples'

describe CitiesController do
  before(:each) { FactoryGirl.create(:hub_city_mapping) }
  after(:each) { clean_dbs :gs_schooldb, :surveys }

  shared_examples_for 'a default cities controller action' do |action, page_name|
    context 'without a hub city mapping' do
      if action == :show
        it 'redirects to state home' do
          get action, state: 'michigan', city: gs_legacy_url_city_encode('foobarnotacity')
          expect(response).to redirect_to(state_url('michigan'))
        end
      else # hub sub-pages
        it 'renders a 404 page' do
          get action, state: 'michigan', city: gs_legacy_url_city_encode('foobarnotacity')
          expect(response).to render_template('error/page_not_found')
        end
      end
    end

    context 'with a hub city mapping' do
      before do
        get action, state: 'michigan', city: gs_legacy_url_city_encode('detroit')
      end

      it 'sets canonical tags' do
        expect(assigns[:canonical_url]).to_not be_nil
      end

      it 'sets city in data_layer' do
        expect(controller.gon.get_variable('data_layer_hash')).to include('City')
      end

      it 'sets state in data_layer' do
        expect(controller.gon.get_variable('data_layer_hash')).to include('State')
      end

      it 'sets collection id in data_layer' do
        expect(controller.gon.get_variable('data_layer_hash')).to include('collection_ids')
      end

      it 'sets page_name in data_layer' do
        expect(controller.gon.get_variable('data_layer_hash')).to include('page_name' => page_name)
      end
    end
  end

  describe 'GET show' do
    it_behaves_like 'a default cities controller action', :show, 'GS:City:Home'
    context 'for inactive cities' do
      before { clean_models :us_geo, City }
      after { clean_models :us_geo, City }
      it 'should redirect to the state page' do
        city = FactoryGirl.create(:city, active: 0)
        allow_any_instance_of(CitiesController).to receive(:set_hub).and_return(nil)
        state_name = States.state_name(city.state)

        get :show, state: state_name, city: gs_legacy_url_city_encode(city.name)
        expect(response).to redirect_to(state_url(state_name))
      end
    end
  end

  describe '#ad_setTargeting_through_gon' do
    subject do
      city_object = double(county: double(name: 'foo'))
      allow(City).to receive(:where).and_return([city_object])
      allow(City).to receive(:popular_cities).and_return(nil)
      get :show, state: 'michigan', city: gs_legacy_url_city_encode('detroit')
      controller.gon.get_variable('ad_set_targeting')
    end

    with_shared_context('when ads are enabled') do
      include_examples 'sets at least one google ad targeting attribute'
      include_examples 'sets the base google ad targeting attributes for all pages'
      include_examples 'sets specific google ad targeting attributes', %w[City State county]
    end

    with_shared_context('when ads are not enabled') do
      include_example 'does not set any google ad targeting attributes'
    end
  end

  describe 'GET events' do
    it_behaves_like 'a default cities controller action', :events, 'GS:City:Events'
  end

  describe 'GET partner' do
    before(:each) do
      FactoryGirl.create(:community_sponsor_collection_config_page_name)
      FactoryGirl.create(:community_sponsor_collection_config_data)
      FactoryGirl.create(:sponsor_page_acro_name_configs)
    end

    it_behaves_like 'a default cities controller action', :partner, 'GS:City:Partner'
  end

  describe 'GET community' do
    it_behaves_like 'a default cities controller action', :community, 'GS:City:EducationCommunity'
  end

  describe 'GET choosing_schools' do
    it_behaves_like 'a default cities controller action', :choosing_schools, 'GS:City:ChoosingSchools'
  end

  describe 'GET enrollment' do
    before do
      pending('TODO: mock out solr')
      fail
    end
    it_behaves_like 'a default cities controller action', :enrollment, 'GS:City:Enrollment'
  end

  describe 'GET programs' do
    it_behaves_like 'a default cities controller action', :programs, 'GS:City:Programs'
  end

  describe '#set_city_home_meta_data' do
    context 'Given Fargo, North Dakota' do
      before do
        subject.instance_variable_set(:@city, 'Fargo')
        subject.instance_variable_set(:@state, {:short => 'nd', :long => 'north dakota'})
        subject.stub(:action_name) { 'show' }
      end
      it "should call set_meta_tags with title" do
        expect(controller).to receive(:set_meta_tags).with(hash_including(:title => "Fargo Schools - Fargo North Dakota School Ratings - Public and Private"))
        controller.send(:write_meta_tags)
      end
    end

  end
end

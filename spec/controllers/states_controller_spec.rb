require 'spec_helper'

shared_examples_for 'a default state controller action' do |action|
  context 'without a hub city mapping' do
    it 'renders an error page' do
      get action, state: 'indiana'
      expect(response).to render_template('error/page_not_found')
    end
  end
end

describe StatesController do
  describe 'GET show' do
    context 'without a hub city mapping' do
      it 'renders state home' do
        get :show, state: 'indiana'
        expect(response).to render_template('states/state_home')
      end
    end

    context 'by default' do
      before(:each) { FactoryGirl.create(:hub_city_mapping, city: nil, state: 'IN') }
      after(:each) { clean_dbs :gs_schooldb }

      it 'sets meta tags' do
        allow(controller).to receive(:set_meta_tags)
        get :show, state: 'indiana'
      end
    end
  end

  describe 'GET enrollment' do
    it_behaves_like 'a default state controller action', :enrollment

    context 'without tab solr results' do
      before(:each) { FactoryGirl.create(:hub_city_mapping, city: nil, state: 'IN') }
      after(:each) { clean_dbs :gs_schooldb }
      let(:empty_tabs) { { :results => { :public => nil, :private => nil } } }

      it 'renders the page' do
        allow(CollectionConfig).to receive(:enrollment_tabs).and_return(empty_tabs)
        get :enrollment, state: 'indiana'
        expect(response).to render_template('shared/enrollment')
      end
    end
  end

  describe 'GET choosing_schools' do
    it_behaves_like 'a default state controller action', :choosing_schools
  end

  describe 'GET guided_search' do
    it 'renders an error page' do
      get :guided_search, state: 'indiana'
      expect(response).to redirect_to(state_url('indiana'))
    end
  end
end

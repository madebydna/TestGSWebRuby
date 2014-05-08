require 'spec_helper'

describe StatesController do
  describe 'GET show' do
    context 'without a mapping' do
      it 'renders an error page' do
        get :show, state: 'indiana'
        expect(response).to render_template('error/page_not_found')
      end
    end
  end

  describe 'GET enrollment' do
    context 'without tab solr results' do
      before(:each) { FactoryGirl.create(:hub_city_mapping, city: nil, state: 'IN') }
      after(:each) { clean_dbs :gs_schooldb }
      let(:empty_tabs) { { :results => { :public => nil, :private => nil } } }

      it 'renders the page' do
        CollectionConfig.stub(:enrollment_tabs).and_return(empty_tabs)
        get :enrollment, state: 'indiana'
        expect(response).to render_template('shared/enrollment')
      end
    end
  end
end

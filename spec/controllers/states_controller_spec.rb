require 'spec_helper'
require 'controllers/contexts/ad_shared_contexts'
require 'controllers/examples/ad_shared_examples'
require 'controllers/examples/rating_methodology_selector_shared_examples'

describe StatesController do
  before(:each) do
    stub_request(:post, /\/solr\/main\/select/).to_return(status: 200, body: "{}", headers: {})
    FactoryBot.create(:hub_city_mapping, city: nil, state: 'IN')
  end

  after(:each) { clean_dbs :gs_schooldb }

  describe 'GET show' do
    it 'should render state home' do
      get :show, state: 'nebraska'
      expect(response).to render_template('states/show')
    end

    it 'sets meta tags' do
      expect(controller).to receive(:set_meta_tags)
      get :show, state: 'indiana'
    end
  end

  describe '#ad_setTargeting_through_gon' do
    subject do
      get :show, state: 'indiana'
      controller.gon.get_variable('ad_set_targeting')
    end

    with_shared_context('when ads are enabled') do
      include_examples 'sets at least one google ad targeting attribute'
      include_examples 'sets the base google ad targeting attributes for all pages'
      include_examples 'sets specific google ad targeting attributes', %w[editorial State]
    end

    with_shared_context('when ads are not enabled') do
      include_example 'does not set any google ad targeting attributes'
    end
  end

  include_examples '#ratings_link'
end

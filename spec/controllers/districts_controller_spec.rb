require 'spec_helper'
require 'controllers/contexts/ad_shared_contexts'
require 'controllers/examples/ad_shared_examples'

describe DistrictsController, type: :controller do
  describe '#ad_setTargeting_through_gon' do
    before do
      FactoryGirl.create(:hub_city_mapping)
      FactoryGirl.create(:district)
      # Currently there a (presumably unused) route in the routes file that will match, and always cause
      # the canonical redirect code to execute. Prevent that
      allow(controller).to receive(:redirect_to_canonical_url) {}
    end
    subject do
      get :show, state: 'california', city: 'alameda', district: 'alameda-city-unified'
      controller.gon.get_variable('ad_set_targeting')
    end
    after do
      clean_models HubCityMapping, City, District
    end

    with_shared_context('when ads are enabled') do
      include_example 'sets at least one google ad targeting attribute'
      include_examples 'sets the base google ad targeting attributes for all pages'
      include_examples 'sets specific google ad targeting attributes', %w[editorial State]
    end

    with_shared_context('when ads are not enabled') do
      include_example 'does not set any google ad targeting attributes'
    end
  end

end

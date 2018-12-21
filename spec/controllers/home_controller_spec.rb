require 'spec_helper'
require 'controllers/contexts/ad_shared_contexts'
require 'controllers/examples/ad_shared_examples'

describe HomeController do

  describe '#ad_setTargeting_through_gon' do
    subject do
      get :show
      controller.gon.get_variable('ad_set_targeting')
    end

    include_example 'sets at least one google ad targeting attribute'
    include_example 'sets the base google ad targeting attributes for all pages'
    include_example 'sets specific google ad targeting attributes', %w[editorial]
  end

end



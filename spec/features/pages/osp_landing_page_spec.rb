require 'spec_helper'
require 'features/page_objects/osp_landing_page'
require 'features/examples/footer_examples'

feature 'OSP landing page' do

  subject do
    visit osp_landing_path
    OspLandingPage.new
  end

  include_examples 'should have a footer'
end

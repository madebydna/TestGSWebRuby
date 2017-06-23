require 'spec_helper'
require 'controllers/contexts/ad_shared_contexts'
require 'controllers/examples/ad_shared_examples'

describe SchoolProfileOverviewController do
  let(:school) { FactoryGirl.build(:school) }
  let(:page) { FactoryGirl.build(:page) }
  let(:page_config) { double(PageConfig) }

  before do
    allow(controller).to receive(:find_school).and_return(school)
    allow(PageConfig).to receive(:new).and_return(page_config)
    allow(page_config).to receive(:name).and_return('overview')
  end

  it 'should have only one action' do
    expect(controller.action_methods.size).to eq(1)
    expect(controller.action_methods - ['overview']).to eq(Set.new)
  end
end

require 'spec_helper'

describe SchoolProfileOverviewController do
  let(:school) { FactoryGirl.build(:school) }
  let(:page) { FactoryGirl.build(:page) }
  let(:page_config) { double(PageConfig) }

  it 'should have only one action' do
    expect(controller.action_methods.size).to eq(1)
    expect(controller.action_methods - ['overview']).to eq(Set.new)
  end

  describe 'GET overview' do
    it_behaves_like 'a configurable profile page', 'overview'
  end

end

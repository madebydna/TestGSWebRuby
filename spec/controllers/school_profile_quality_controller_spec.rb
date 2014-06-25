require 'spec_helper'

describe SchoolProfileQualityController do
  let(:school) { FactoryGirl.build(:school) }
  let(:page) { FactoryGirl.build(:page) }
  let(:page_config) { double(PageConfig) }

  it 'should have only one action' do
    expect(controller.action_methods.size).to eq(1)
    expect(controller.action_methods - ['quality']).to eq(Set.new)
  end

  describe 'GET quality' do
    it_behaves_like 'a configurable profile page', 'quality'
  end

end

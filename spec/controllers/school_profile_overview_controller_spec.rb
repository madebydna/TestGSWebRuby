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

  describe 'GET overview' do
    it_behaves_like 'a configurable profile page', 'overview'
  end

  describe '#ad_setTargeting_through_gon' do
    before do
      controller.instance_variable_set(:@school, school.extend(SchoolProfileDataDecorator) )
      school.level_code = 'e'
      school.county =  'some county'
      school.zipcode = '90210'
      allow(school).to receive(:gs_rating) { '9' }
      allow(school).to receive(:district) { double('district', FIPScounty: 1) }
    end
    subject do
      get 'overview', controller.view_context.school_params(school)
      controller.gon.get_variable('ad_set_targeting')
    end

    context 'when ads are enabled' do
      before do
        allow(school).to receive(:show_ads) { true }
      end

      include_examples 'sets at least one google ad targeting attribute'
      include_examples 'sets the base google ad targeting attributes for all pages'
      include_examples 'sets specific google ad targeting attributes', %w[City county gs_rating level school_id State type zipcode district_id]
    end

    context 'when ads are not enabled' do
      before do
        allow(school).to receive(:show_ads) { false }
      end
      include_example 'does not set any google ad targeting attributes'
    end
  end

end

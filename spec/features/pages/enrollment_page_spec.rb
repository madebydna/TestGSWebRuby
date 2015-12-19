require 'spec_helper'
require 'features/page_objects/city_home_page'
require_relative '../features/examples/page_examples'
require_relative '../features/contexts/state_home_contexts'

def setup(collection_id, nickname)
  FactoryGirl.create(:important_events_collection_config, collection_id: collection_id)
  FactoryGirl.create(:collection_nickname, value: nickname, collection_id: collection_id)
  FactoryGirl.create(:enrollment_module_configs, quay: 'enrollmentPage_private_preschool_module', collection_id: collection_id)
  FactoryGirl.create(:enrollment_module_configs, quay: 'enrollmentPage_public_preschool_module', collection_id: collection_id)
end

describe 'Enrollment Page' do
  after(:each) { clean_dbs :gs_schooldb }

  context 'on a city enrollment page' do
    before(:each) do
      setup(1, 'Detroit')
      FactoryGirl.create(:hub_city_mapping)
      visit '/michigan/detroit/enrollment'
    end

    it 'includes a basic hub page layout' do
      # Header
      expect(page).to have_no_selector('.upcoming-event', count: 2)
      expect(page).to have_selector('.navbar')
      expect(page).to have_text('Find a school in Detroit')

      # Tabs
      expect(page).to have_link('Preschools')
      expect(page).to have_link('Elementary schools')
      expect(page).to have_link('Middle schools')
      expect(page).to have_link('High schools')

      # Footer
      expect(page).to have_text('Find the great schools in Michigan')
      expect(page).to have_selector('.js-city-list')
    end
    describe 'breadcrumbs' do
      subject { CityHomePage.new }

      it { is_expected.to have_breadcrumbs }
      its('first_breadcrumb.title') { is_expected.to have_text('Michigan') }
      its('first_breadcrumb') { is_expected.to have_link('Michigan', href: "/michigan/") }
      its('second_breadcrumb.title') { is_expected.to have_text('Detroit') }
      its('second_breadcrumb') { is_expected.to have_link('Detroit', href: "/michigan/detroit/") }
    end
  end

  context 'on a state enrollment page' do
    before(:each) do
      setup(6, 'Indiana')
      FactoryGirl.create(:hub_city_mapping, city: nil, state: 'in', collection_id: 6)
      visit '/indiana/enrollment'
    end

    it 'includes a basic hub page layout' do
      # Header
      expect(page).to have_selector('.navbar')
      expect(page).to have_text('Find a school in Indiana')

      # Tabs
      expect(page).to have_link('Preschools')
      expect(page).to have_link('Elementary schools')
      expect(page).to have_link('Middle schools')
      expect(page).to have_link('High schools')

      # Footer
      expect(page).to have_text('Find the great schools in Indiana')
      expect(page).to have_selector('.js-city-list')
    end

  end

end

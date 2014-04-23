require 'spec_helper'

describe 'Enrollment Page' do
  before(:each) do
    FactoryGirl.create(:hub_city_mapping)
    FactoryGirl.create(:important_events_collection_config)
    FactoryGirl.create(:collection_nickname, value: 'Detroit')
    FactoryGirl.create(:enrollment_module_configs, quay: 'enrollmentPage_private_preschool_module')
    FactoryGirl.create(:enrollment_module_configs, quay: 'enrollmentPage_public_preschool_module')
  end
  before(:each) { visit '/michigan/detroit/enrollment' }
  after(:each) { clean_dbs :gs_schooldb }

  it 'includes a basic hub page layout' do
    # Header
    expect(page).to have_selector('.upcoming-event', count: 2)
    expect(page).to have_selector('.navbar')
    expect(page).to have_text('Find a school in Detroit')

    # Tabs
    expect(page).to have_link('Preschools')
    expect(page).to have_link('Elementary schools')
    expect(page).to have_link('Middle schools')
    expect(page).to have_link('High schools')

    # Footer
    expect(page).to have_text('Find the great schools in Michigan')
    expect(page).to have_selector('#footer .js-city-list')
  end
end

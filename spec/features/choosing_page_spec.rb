require 'spec_helper'

describe 'Choosing Page' do
  before(:each) { CollectionConfig.destroy_all }
  before(:each) do
    FactoryGirl.create(:choosing_page_links_configs)
    FactoryGirl.create(:important_events_collection_config)
  end

  it 'displays basic static content' do
    visit '/michigan/detroit/choosing-schools/'

    expect(page.title).to eq('Choosing a school in Detroit, MI')
    expect(page).to have_selector('h1', text: '5 simple steps to')
    expect(page).to have_selector('.expandable', count: 4)
  end

  it 'displays dynamic content' do
  end
end

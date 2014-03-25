require 'spec_helper'

describe 'Choosing Page' do
  before(:each) do
    CollectionConfig.destroy_all
    HubCityMapping.destroy_all
    FactoryGirl.create(:choosing_page_links_configs)
    FactoryGirl.create(:important_events_collection_config)
    FactoryGirl.create(:hub_city_mapping)
  end

  it 'displays basic static and dynamic content' do
    visit '/michigan/detroit/choosing-schools/'

    expect(page.title).to eq('Choosing a school in Detroit, MI')
    expect(page).to have_selector('h1', text: '5 simple steps to')
    expect(page).to have_selector('.expandable', count: 4)

    step3_links = CollectionConfig.choosing_page_links(1)
    step3_links.each do |link|
      expect(page).to have_link(link[:name], href: link[:path])
    end
  end
end

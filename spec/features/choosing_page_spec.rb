require 'spec_helper'

describe 'Choosing Page' do

  after(:each) { clean_dbs :gs_schooldb }
  let(:configs) { CollectionConfig.all }

  context 'on a city choosing page' do
    before(:each) do
      FactoryGirl.create(:hub_city_mapping)
      FactoryGirl.create(:choosing_page_links_configs)
      FactoryGirl.create(:important_events_collection_config)
    end

    it 'displays basic static and dynamic content' do
      visit '/michigan/detroit/choosing-schools/'

      expect(page.title).to eq('Choosing a school in Detroit, MI')
      expect(page).to have_selector('h1', text: '5 simple steps to')
      expect(page).to have_selector('.expandable', count: 4)

      step3_links = CollectionConfig.choosing_page_links(configs)
      step3_links.each do |link|
        expect(page).to have_link(link[:name], href: link[:path])
      end
    end
  end

  context 'on a state choosing page' do
    before(:each) do
      FactoryGirl.create(:hub_city_mapping, collection_id: 6, city: nil, state: 'in')
      FactoryGirl.create(:choosing_page_links_configs, collection_id: 6)
      FactoryGirl.create(:important_events_collection_config, collection_id: 6)
    end

    it 'displays basic static and dynamic content' do
      visit '/indiana/choosing-schools/'

      expect(page.title).to eq('Choosing a school in Indiana')
      expect(page).to have_selector('h1', text: '5 simple steps to')
      expect(page).to have_selector('.expandable', count: 4)

      step3_links = CollectionConfig.choosing_page_links(configs)
      step3_links.each do |link|
        expect(page).to have_link(link[:name], href: link[:path])
      end
    end
  end
end

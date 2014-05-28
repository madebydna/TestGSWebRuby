require 'spec_helper'

shared_examples_for 'it displays static and dynamic content' do |opts|
  let(:title) { opts[:title] }

  it 'displays basic static and dynamic content' do
    expect(page.title).to eq(title)
    expect(page).to have_selector('h1', text: '5 simple steps to')
    expect(page).to have_selector('.js-expandable', count: 4)

    step3_links = CollectionConfig.choosing_page_links(configs)
    step3_links.each do |link|
      expect(page).to have_link link[:name], href: link[:path]
    end
  end
end

describe 'Choosing Page' do
  after(:each) { clean_dbs :gs_schooldb }
  let(:configs) { CollectionConfig.all }

  context 'on a city choosing page' do
    before(:each) do
      FactoryGirl.create :hub_city_mapping
      FactoryGirl.create :choosing_page_links_configs
      FactoryGirl.create :important_events_collection_config
      visit '/michigan/detroit/choosing-schools/'
    end

    it_behaves_like 'it displays static and dynamic content', { title: 'Choosing a school in Detroit, MI' }
  end

  context 'on a state choosing page' do
    before(:each) do
      FactoryGirl.create(:hub_city_mapping, collection_id: 6, city: nil, state: 'in')
      FactoryGirl.create(:choosing_page_links_configs, collection_id: 6)
      FactoryGirl.create(:important_events_collection_config, collection_id: 6)
      visit '/indiana/choosing-schools/'
    end

    it_behaves_like 'it displays static and dynamic content', { title: 'Choosing a school in Indiana' }
  end
end

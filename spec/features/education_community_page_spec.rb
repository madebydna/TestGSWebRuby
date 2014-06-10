require 'spec_helper'

describe 'Education Comunity Page' do
  after(:each) { clean_dbs :gs_schooldb }
  before(:each) do
    FactoryGirl.create(:hub_city_mapping)
    FactoryGirl.create(:community_tabs_collection_config)
    FactoryGirl.create(:community_partners_subheading_collection_config)
    FactoryGirl.create(:community_partners_collection_config)
    FactoryGirl.create(:important_events_collection_config)
    CollectionConfig.where(quay: CollectionConfig::NICKNAME_KEY, collection_id: 1, value: 'Detroit').first_or_create
    visit '/michigan/detroit/education-community'
  end

  describe 'search bar' do
    it 'exists' do
      expect(page).to have_content 'Find a school in Detroit'
      expect(page).to have_content 'Not in Detroit?'
      expect(page).to have_css '#js-findByNameBox'
    end
  end

  describe 'upcoming events module' do
    it 'shows 2 upcoming events' do
      expect(page).to have_css '.upcoming-event', count: 2
    end
  end

  describe 'heading' do
    it 'shows the heading and subheading' do
      expect(page).to have_content 'Detroit Education Community'
      expect(page).to have_content "Education doesn't happen in a vacuum"
    end
  end

  describe 'body' do
    it 'shows community partners' do
      expect(page).to have_css('.community-partner-row', count: 11)
    end

    it 'shows links to other education community pages' do
      expect(page).to have_link('Education', href: 'education')
      expect(page).to have_link('Funders', href: 'funders')
    end
  end
end


describe 'Education Community Partner Page' do
  after(:each) { clean_dbs :gs_schooldb }
  before(:each) do
    FactoryGirl.create(:hub_city_mapping)
    FactoryGirl.create(:community_sponsor_collection_config_data)
    FactoryGirl.create(:sponsor_page_page_name_configs)
    FactoryGirl.create(:sponsor_page_acro_name_configs)

    visit '/michigan/detroit/education-community/partner'
  end

  it 'sets meta tags based on the page and acro names' do
    meta_tags = page.all('meta', visible: false)
    description_tag = meta_tags.select { |tag| tag[:name] == 'description' }
    keywords_tag = meta_tags.select { |tag| tag[:name] == 'keywords' }

    expect(description_tag).to_not be_nil
    expect(keywords_tag).to_not be_nil
  end

  it 'displays partner information' do
    expect(page).to have_selector('h2', text: 'Excellent Schools Detroit - ESD')
    expect(page).to have_selector("img[alt='Partner Logo']")
    expect(page).to have_link("Find out more about ESDs education Plan")
  end
end


describe 'State Education Comunity Page' do
  after(:each) { clean_dbs :gs_schooldb }
  before(:each) do
    FactoryGirl.create(:hub_city_mapping)
    FactoryGirl.create(:community_tabs_collection_config)
    FactoryGirl.create(:community_partners_subheading_collection_config)
    FactoryGirl.create(:community_partners_collection_config)
    FactoryGirl.create(:important_events_collection_config)
    CollectionConfig.where(quay: CollectionConfig::NICKNAME_KEY, collection_id: 1, value: 'Detroit').first_or_create
    visit '/indiana/education-community'
  end

  describe 'search bar' do
    it 'exists' do
      expect(page).to have_content 'Find a school in Detroit'
      expect(page).to have_content 'Not in Detroit?'
      expect(page).to have_css '#js-findByNameBox'
    end
  end

  describe 'upcoming events module' do
    it 'shows 2 upcoming events' do
      expect(page).to have_css '.upcoming-event', count: 2
    end
  end

  describe 'heading' do
    it 'shows the heading and subheading' do
      expect(page).to have_content 'Detroit Education Community'
      expect(page).to have_content "Education doesn't happen in a vacuum"
    end
  end

  describe 'body' do
    it 'shows community partners' do
      expect(page).to have_css('.community-partner-row', count: 11)
    end

    it 'shows links to other education community pages' do
      expect(page).to have_link('Education', href: 'education')
      expect(page).to have_link('Funders', href: 'funders')
    end
  end
end


describe 'State Education Community Partner Page' do
  after(:each) { clean_dbs :gs_schooldb }
  before(:each) do
    FactoryGirl.create(:hub_city_mapping)
    FactoryGirl.create(:community_sponsor_collection_config_data)
    FactoryGirl.create(:sponsor_page_page_name_configs)
    FactoryGirl.create(:sponsor_page_acro_name_configs)

    visit '/michigan/detroit/education-community/partner'
  end

  it 'sets meta tags based on the page and acro names' do
    meta_tags = page.all('meta', visible: false)
    description_tag = meta_tags.select { |tag| tag[:name] == 'description' }
    keywords_tag = meta_tags.select { |tag| tag[:name] == 'keywords' }

    expect(description_tag).to_not be_nil
    expect(keywords_tag).to_not be_nil
  end

  it 'displays partner information' do
    expect(page).to have_selector('h2', text: 'Excellent Schools Detroit - ESD')
    expect(page).to have_selector("img[alt='Partner Logo']")
    expect(page).to have_link("Find out more about ESDs education Plan")
  end
end

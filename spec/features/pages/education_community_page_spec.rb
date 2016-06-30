require 'spec_helper'
require 'features/page_objects/city_home_page'
require 'features/examples/page_examples'
require 'features/contexts/state_home_contexts'
require 'features/examples/footer_examples'

describe 'Education Community Page' do
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
  subject { CityHomePage.new }


  include_examples 'should have a footer'

  describe 'breadcrumbs' do
    it { is_expected.to have_breadcrumbs }
    its('first_breadcrumb.title') { is_expected.to have_text('Michigan') }
    its('first_breadcrumb') { is_expected.to have_link('Michigan', href: "/michigan/") }
    its('second_breadcrumb.title') { is_expected.to have_text('Detroit') }
    its('second_breadcrumb') { is_expected.to have_link('Detroit', href: "/michigan/detroit/") }
  end

  describe 'search bar' do
    it 'exists' do
      expect(page).to have_content 'Find a school in Detroit'
      expect(page).to have_content 'Not in Detroit?'
      expect(page).to have_css '#js-findByNameBox'
    end
  end

  describe 'upcoming events module' do
    it 'does not show upcoming events' do
      expect(page).to_not have_css '.upcoming-event'
    end
  end

  describe 'heading' do
    it 'shows the heading and subheading' do
      expect(page).to have_content 'Detroit Education Community'
      expect(page).to have_content "Education doesn't happen in a vacuum"
    end
  end

  describe 'body' do
    it 'shows links to other education community pages' do
      expect(page).to have_link('Education', href: '/michigan/detroit/education-community/education')
      expect(page).to have_link('Funders', href: '/michigan/detroit/education-community/funders')
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
  subject { CityHomePage.new }
  include_examples 'should have a footer'

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


describe 'State Education Community Page' do
  after(:each) { clean_dbs :gs_schooldb }
  before(:each) do
    FactoryGirl.create(:hub_city_mapping, collection_id: 6, city: nil, state: 'in')
    FactoryGirl.create(:community_tabs_collection_config, collection_id: 6)
    FactoryGirl.create(:community_partners_subheading_collection_config, collection_id: 6)
    FactoryGirl.create(:community_partners_collection_config, collection_id: 6)
    CollectionConfig.where(quay: CollectionConfig::NICKNAME_KEY, collection_id: 6, value: 'Indiana').first_or_create
    visit '/indiana/education-community'
  end

  describe 'search bar' do
    it 'exists' do
      expect(page).to have_content 'Find a school in Indiana'
      expect(page).to have_content 'Not in Indiana?'
      expect(page).to have_css '#js-findByNameBox'
    end
  end

  describe 'heading' do
    it 'shows the heading and subheading' do
      expect(page).to have_content 'Indiana Education Community'
      expect(page).to have_content "Education doesn't happen in a vacuum"
    end
  end

  describe 'body' do
    it 'shows links to other education community pages' do
      expect(page).to have_link('Education', href: '/indiana/education-community/education')
      expect(page).to have_link('Funders', href: '/indiana/education-community/funders')
    end
  end
end


describe 'State Education Community Partner Page' do
  after(:each) { clean_dbs :gs_schooldb }
  before(:each) do
    FactoryGirl.create(:hub_city_mapping, collection_id: 6)
    FactoryGirl.create(:community_sponsor_collection_config_data, collection_id: 6)
    FactoryGirl.create(:sponsor_page_page_name_configs, collection_id: 6)
    FactoryGirl.create(:sponsor_page_acro_name_configs, collection_id: 6)
    FactoryGirl.create(:community_show_tabs_config, collection_id: 6)

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

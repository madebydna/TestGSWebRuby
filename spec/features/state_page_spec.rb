require 'spec_helper'

describe 'State Page' do
  describe 'layout' do
    before(:each) do
      FactoryGirl.create(:feature_articles_collection_config, collection_id: 6)
      FactoryGirl.create(:collection_nickname, collection_id: 6)
      FactoryGirl.create(:state_hub_mapping)
      FactoryGirl.create(:state_hub_content_module)
      FactoryGirl.create(:state_partners_configs)
    end
    after(:each) { clean_dbs :gs_schooldb }
    before(:each) { visit '/indiana' }

    it 'has the navigation element' do
      expect(page).to have_selector('.navbar-fixed-top')
    end

    it 'has the search hero' do
      expect(page).to have_selector('.hub-hero-bg')
      expect(page).to have_text('Find a School in')
    end

    it 'has the content module' do
      expect(page).to have_content 'State report cards for public schools'
    end
    it 'has the partners module' do
      expect(page).to have_selector('.js-partners')
    end
  end
end

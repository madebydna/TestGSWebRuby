require 'spec_helper'

describe 'City Hub Page' do
  let(:city_page_url) { '/michigan/detroit' }
  before(:each) do
    FactoryGirl.create(:hub_city_mapping)
    FactoryGirl.create(:important_events_collection_config)
    FactoryGirl.create(:city_hub_sponsor_collection_config)
    FactoryGirl.create(:feature_articles_collection_config)
    FactoryGirl.create(:city_hub_partners_collection_config)
    FactoryGirl.create(:announcement_collection_config)
    FactoryGirl.create(:show_announcement_collection_config)
    FactoryGirl.create(:choose_a_school_collection_configs)
    FactoryGirl.create(:collection_nickname)
  end
  after(:each) { clean_dbs :gs_schooldb }

  before(:each) { visit city_page_url }

  describe 'search' do
    it 'displays sponsor information' do
      expect(page).to have_css("a[href='/michigan/detroit/education-community/partner/']")
      expect(page).to have_xpath("//img[@alt='sponsor logo']")
    end
  end

  describe 'choose a school section' do
    it 'renders links for a city hub' do
      expect(page).to have_content 'Finding a Great School in Detroit'
      expect(page).to have_selector('.scale-image')
    end
  end

  describe 'upcoming events section' do
    it 'shows 2 upcoming events' do
      expect(page).to have_css('.upcoming-event', count: 2)
    end
    it 'shows announcements' do
      expect(page).to have_css('.alert-success')
      expect(page).to have_css('strong', text: 'ANNOUNCEMENT', count: 1)
      expect(page).to have_link 'Learn More'
    end
  end

  describe 'featured articles section' do
    it 'display featured articles' do
      article_title = 'How to spot a world-class education'
      expect(page).to have_content article_title
    end
    it 'shows nearby homes with zillow' do
      expect(page).to have_content 'Nearby Homes for Sale'
      expect(page).to have_css('iframe')
    end
  end

  describe 'education community carousel' do
    it 'shows the carousel' do
      expect(page).to have_css('.js-partner-carousel')
    end
  end
end

require 'spec_helper'


def setup(collection_id, nickname)
  FactoryGirl.create(:collection_nickname, value: nickname, collection_id: collection_id)
end

feature 'Guided Search Page' do

  after(:each) { clean_dbs :gs_schooldb }
  feature 'on a state guided Search page' do
    before(:each) do
      setup(6, 'Indiana')
      FactoryGirl.create(:hub_city_mapping, city: nil, state: 'in', collection_id: 6)
      visit '/indiana/guided-search'
    end

    it 'includes a basic page layout with nav bar ' do
      # Header
      expect(page).to have_selector('.navbar')
      # Page Does not have Footer
      expect(page).to_not have_selector('.js-city-list')
    end
    it 'includes Help me find a school title module on page' do
      expect(page).to have_selector( 'h3','Help me find a School')

    end
    it 'includes guided search navigation options' do
      # Navigation
      expect(page).to have_text('Get Started')
      expect(page).to have_text('Child Care')
      expect(page).to have_text('Dress Code')
      expect(page).to have_text('School Focus')
      expect(page).to have_text('Class Offerings')
      #Have Next Button
      expect(page).to have_css('.js-guided-search-next')

    end
    it 'includes guided search styling options for active inactive navigation options' do
      expect(page).to have_css('.js-tab-number', count: 5)
      expect(page).to have_css('.js-tab-check', count: 5)


    end

    feature 'Navigating steps' do
      pending 'Pending until Jenkins works with webkit'
      (1..5).each do |step|
        it "when I go to step #{step} by clicking next then I should see #{step - 1} completed steps", js:true do
          # save_and_open_page
          (step - 1).times.each { find(:css, ".js-guided-search-next").click }
          expect(page).to have_css('.js-tab-check.i-24-checkmark-on', count: step - 1 )
        end
      end


    end
  end


end

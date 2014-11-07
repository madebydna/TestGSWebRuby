require 'spec_helper'


def setup(collection_id, nickname)
  FactoryGirl.create(:collection_nickname, value: nickname, collection_id: collection_id)
end

feature 'Guided Search Page' do

  after(:each) { clean_dbs :gs_schooldb }
  feature 'on a state guided Search page' do
    before(:each) do
      setup(9, 'Delaware')
      FactoryGirl.create(:hub_city_mapping, city: nil, state: 'de', collection_id: 9, hasGuidedSearch: true)
      visit '/delaware/guided-search'
    end

    it 'includes a basic page layout with nav bar ' do
      # Header
      expect(page).to have_selector('.navbar')
    end
    it 'includes Help me find a school title module on page' do
      expect(page).to have_selector( 'h3', 'Discover schools that match your needs')

    end
    it 'includes guided search navigation options' do
      # Navigation
      expect(page).to have_text('Get Started')
      expect(page).to have_text('Before/After care')
      expect(page).to have_text('Dress code')
      expect(page).to have_text('School focus')
      expect(page).to have_text('Classes and activities')
      #Have Next Button
      expect(page).to have_css('.js-guided-search-next')

    end
    it 'includes guided search styling options for active inactive navigation options' do
      expect(page).to have_css('.js-tab-number', count: 5)
      expect(page).to have_css('.js-tab-check', count: 5)


    end

    feature 'Navigating steps' do
      (1..5).each do |step|
        it "when I go to step #{step} by clicking next then I should see #{step - 1} completed steps", js:true do
          pending 'Pending until Jenkins works with webkit. This also needs to be rewritten since the form has JS validation now.'
          fail
          # save_and_open_page
          (step - 1).times.each { find(:css, ".js-guided-search-next").click }
          expect(page).to have_css('.js-tab-check.i-24-checkmark-on', count: step - 1 )
        end
      end


    end
  end


end

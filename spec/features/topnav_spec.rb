require 'spec_helper'

feature 'Topnav' do

  it 'shows a city hub title if cookies are set' do
    page.driver.browser.set_cookie("hubState=MI")
    page.driver.browser.set_cookie("hubCity=Detroit")
    visit '/alaska/'
    within('.navbar-fixed-top') do
      expect(page).to have_text 'Detroit, MI'
    end
  end

  it 'shows a state hub title if cookies are set' do
    page.driver.browser.set_cookie("hubState=MI")
    visit '/alaska/'
    within('.navbar-fixed-top') do
      expect(page).to have_text 'Michigan Home'
    end
  end

  it 'does not show a local hub title if cookies are not set' do
    visit '/alaska/'
    within('.navbar-fixed-top') do
      expect(page).to_not have_text 'Alaska Home'
    end
  end

  feature 'On a page with a city and state' do
    after(:each) do
      clean_models(HubCityMapping)
    end
    it 'finds a hub matching the state but not matching the city' do
      state_hub_mapping = FactoryGirl.create(:state_hub_mapping, state: 'ca')
      visit '/california/?city=alameda'
      within('.navbar-fixed-top') do
        expect(page).to have_text 'California Home'
      end
    end
    it 'finds a hub matching the state and city, case-insensitive' do
      state_hub_mapping = FactoryGirl.create(:state_hub_mapping, state: 'ca', city: 'Alameda')
      visit '/california/?city=alameda'
      within('.navbar-fixed-top') do
        expect(page).to have_text 'Alameda, CA'
      end
    end
  end

  feature 'On state hub pages' do
    let!(:state_hub_mapping) { FactoryGirl.create(:state_hub_mapping, state: 'ak') }
    subject do
      visit '/alaska'
      page
    end
    before { subject }
    after(:each) do
      clean_models(HubCityMapping)
    end
    it 'shows the state hub title' do
      within('.navbar-fixed-top') do
        expect(subject).to have_text "Alaska Home"
      end
    end
    it 'shows the state hub title even if cookies show a different hub' do
      page.driver.browser.set_cookie("hubState=MI")
      page.driver.browser.set_cookie("hubCity=Detroit")
      within('.navbar-fixed-top') do
        expect(subject).to have_text "Alaska Home"
      end
    end
  end


  
end
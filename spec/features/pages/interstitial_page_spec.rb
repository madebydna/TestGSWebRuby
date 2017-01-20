require "spec_helper"

describe "Visitor" do
  after do
    clean_dbs(:ca)
  end

  scenario "sees an interstitial ad page" do
    visit interstitial_ad_path
    ad_message = "GreatSchools thanks the foundations"

    expect(page).to have_content(ad_message)
    expect(page).to have_ad
  end

  scenario "visitor navigates to destination url from interstitial page", js: true do
    school = create(:alameda_high_school)
    expected_url = school_url(school)
    visit interstitial_ad_path({passThroughURI: expected_url}) 

    click_on_skip_ad_link

    expect(page.current_url).to eq(expected_url)
  end

  def click_on_skip_ad_link
    page.first(".js-continueToDestination").click
  end

  def have_ad
    have_css('div[data-dfp="Interstitial"]')
  end
end

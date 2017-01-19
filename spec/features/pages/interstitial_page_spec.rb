require "spec_helper"

describe "Visitor" do
  scenario "sees an interstitial ad page" do
    visit interstitial_ad_path

    ad_message = "GreatSchools thanks the foundations"
    expect(page).to have_content(ad_message)
    expect(page).to have_css('div[data-dfp="Interstitial"]')
  end
end

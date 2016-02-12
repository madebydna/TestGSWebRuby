require 'spec_helper'
require 'features/page_objects/home_page'
require 'features/page_objects/account_page'
require 'features/examples/footer_examples'
require 'features/contexts/shared_contexts_for_signed_in_users'

describe 'Home Page' do
  before { visit home_path }
  subject(:page_object) { HomePage.new }

  it { is_expected.to have_search_hero_section }
  it { is_expected.to have_browse_by_city_header }
  it { is_expected.to have_browse_by_cities_section }
  it { is_expected.to have_email_signup_section }
  it { is_expected.to_not have_greatkids_articles_section }
  it { is_expected.to have_offers_section }
  with_subject :offers_section do
    it { is_expected.to have_for_families_link }
    it { is_expected.to have_for_schools_link }
    it { is_expected.to have_write_a_review_link }
    it { is_expected.to have_search_by_address_link }
  end
  it { is_expected.to have_quote_section }
  it { is_expected.to have_who_we_are_section }
  it { is_expected.to have_our_supporters_section }
  include_examples 'should have a footer'

  context 'when browsing by city' do
    list_of_cities = [
      "Atlanta, GA",
      "Austin, TX",
      "Boston, MA",
      "Brooklyn, NY",
      "Charlotte, NC",
      "Chicago, IL",
      "Dallas, TX",
      "Denver, CO",
      "Houston, TX",
      "Indianapolis, IN",
      "Las Vegas, NV",
      "Los Angeles, CA",
      "Miami, FL",
      "Nashville, TN",
      "New York City, NY",
      "Orlando, FL",
      "Philadelphia, PA",
      "Phoenix, AZ",
      "San Antonio, TX",
      "San Diego, CA",
      "San Francisco, CA",
      "Seattle, WA",
      "Tampa, FL",
      "Washington, DC"
    ]

    with_subject(:browse_by_cities_section) do
      its("cities.length") { should eq(24) }
      it 'should match the given list of cities' do
        list_of_cities.each_with_index do | city, index |
          expect(subject.cities[index].text).to eq(city)
        end
      end
    end
  end

  context 'when configured to show greatkids banner' do
    before do
      Rails.cache.clear
      FactoryGirl.create(:property_config, quay: 'homePageGreatKidsMilestoneBannerActive', value: 'true')
      visit home_path
      wait_for_page_to_finish
    end
    after do
      clean_models :gs_schooldb, PropertyConfig
    end
    it { is_expected.to have_search_hero_section }
    it { is_expected.to have_high_chool_milesontes_section }
    it { is_expected.to have_common_core_banner_section }
  end

  context 'when I click the "sign up for email updates" button', js: true do
    before { page_object.email_signup_section.submit_button.click }
    after { clean_dbs :gs_schooldb }
    with_subject(:email_join_modal) do
      before do
        pending('failing because of this commit f4f61f3'); fail;
      end
      it { is_expected.to be_visible }
      when_I :sign_up_with_email, 'email@example.com' do
        its(:parent_page) { is_expected.to have_flash_message('You\'ve signed up to receive updates.') }
      end
    end
  end

  with_shared_context 'signed in verified user', js: true do
    context 'when I click the "sign up for email updates" button' do
      before do
        pending('failing because of this commit 46edb229, needs to be fixed')
        fail
        visit home_path
        page_object.email_signup_section.submit_button.click
      end
      after { clean_dbs :gs_schooldb }
      it { is_expected.to_not have_email_join_modal }
      it { is_expected.to have_flash_message('You\'ve signed up to receive updates.') }
    end
  end

  context 'when configured to have greatkids content' do
    before do
      Rails.cache.clear
      FactoryGirl.create(:homepage_features_external_content)
      visit home_path
      wait_for_page_to_finish
    end
    after do
      clean_models :gs_schooldb, ExternalContent
    end
    it { is_expected.to have_greatkids_articles_section }
  end

  context 'top nav' do
    include_context 'signed in verified user'
    before { visit home_path }
    it { is_expected.to have_top_nav }
    when_I :click_on_my_school_list_link do
      it 'should go to the account page' do
        expect(AccountPage.new).to be_displayed
      end
    end
  end

end

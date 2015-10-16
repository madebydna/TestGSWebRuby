require 'spec_helper'
require_relative 'city_home_page'
require_relative '../examples/page_examples'
require_relative '../contexts/state_home_contexts'

describe 'City Home Page' do
  before do
    create(:city, state: 'MN', name: 'St. Paul')
    visit city_path('minnesota', 'st.-paul')
  end
  after { clean_dbs :us_geo }
  subject(:page_object) { CityHomePage.new }

  # PT-1347 This is a test in itself because this URL used to be unreachable
  include_example 'should have url path', '/minnesota/st.-paul/'

  it { is_expected.to have_email_signup_section }

  context 'when I click the "sign up for email updates" button', js: true do
    before { page_object.email_signup_section.submit_button.click }
    after { clean_dbs :gs_schooldb }
    with_subject(:email_join_modal) do
      it { is_expected.to be_visible }
      when_I :sign_up_with_email, 'email@example.com' do
        its(:parent_page) { is_expected.to have_flash_message('You\'ve signed up to receive updates.') }
      end
    end
  end

  with_shared_context 'signed in verified user', js: true do
    context 'when I click the "sign up for email updates" button' do
      before do
        visit home_path
        page_object.email_signup_section.submit_button.click
      end
      after { clean_dbs :gs_schooldb }
      it { is_expected.to_not have_email_join_modal }
      it { is_expected.to have_flash_message('You\'ve signed up to receive updates.') }
    end
  end

  describe 'Browse school links' do
    it { is_expected.to have_preschool_link }
    it { is_expected.to have_elementary_link }
    it { is_expected.to have_middle_link }
    it { is_expected.to have_high_link }
    it { is_expected.to have_public_district_link }
    it { is_expected.to have_private_link }
    it { is_expected.to have_public_charter_link }
    it { is_expected.to have_view_all_link }
    describe 'Follow the links' do
      on_subject :click_on_preschool_link do
        it 'should navigate to a preschool school list' do
          expect(current_path).to eq('/minnesota/st.-paul/schools/')
          expect(page.title).to include('St. Paul')
          expect(page.title).to include('Preschools')

        end
      end
    end
  end
  describe 'City rating on page' do
    # TODO: Set up city_rating
    #it { is_expected.to have_city_rating}
  end
end

require 'spec_helper'
require 'features/page_objects/city_home_page'
require 'features/examples/page_examples'
require 'features/contexts/state_home_contexts'
require 'features/examples/top_rated_schools_section_examples'
require 'features/contexts/shared_contexts_for_signed_in_users'
require 'features/examples/footer_examples'

describe 'City Home Page' do
  let!(:city) { create(:city, state: 'MN', name: 'St. Paul') }
  after { clean_dbs :us_geo, :mn }
  subject(:page_object) do
    visit city_path('minnesota', 'st.-paul')
    CityHomePage.new
  end

  include_examples 'should have a footer'
  its(:current_path) { is_expected.to eq '/minnesota/st.-paul/' }
  it { is_expected.to have_email_signup_section }

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
        pending ('failing feature test from commit 8f32743, needs to be fixed')
        fail
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
      before { pending('pending because solr dependency'); fail }
      on_subject :click_on_preschool_link do
        it 'should navigate to a preschool school list' do
          expect(current_path).to eq('/minnesota/st.-paul/schools/')
          expect(page.title).to include('St. Paul')
          expect(page.title).to include('Preschools')

        end
      end
    end
  end

  describe 'Top rated schools' do
    let!(:top_rated_schools) { CityHomePageFactory.new.create_top_rated_schools('MN', 'St. Paul') }
    let(:heading_object) { city }
    after { clean_dbs :gs_schooldb, :ca, :mn }
    it_behaves_like 'page with top rated schools section'
  end

  describe 'City rating' do
    context 'with a city rating' do
      let!(:city_rating) do
        rating = FactoryGirl.build(:city_rating, city: 'St. Paul', rating: '10')
        rating.on_db(:mn).save
      end
      before { visit city_path('minnesota', 'st.-paul') }
      after { clean_dbs :mn }
      it { is_expected.to have_city_rating }
      its(:city_rating) { is_expected.to have_rating('10') }
    end
    context 'without city rating' do
      it { is_expected.to have_city_rating }
      its(:city_rating) { is_expected.to be_not_rated }
    end
  end

  describe 'breadcrumbs' do
    it { is_expected.to have_breadcrumbs }
    its('first_breadcrumb.title') { is_expected.to have_text('Minnesota') }
    its('first_breadcrumb') { is_expected.to have_link('Minnesota', href: "/minnesota/") }
  end

  describe 'largest districts' do
    context 'with three districts' do
      let!(:districts) do
        [2,3,1].each do |num_schools|
          FactoryGirl.create_on_shard(:mn, :district, name: 'foo', city: 'St. Paul', state: 'MN', num_schools: num_schools)
        end
      end
      it { is_expected.to have_largest_districts_section }
      with_subject :largest_districts_section do
        its('districts.length') { is_expected.to eq(3) }
        its('first_district') { is_expected.to have_district_link }
        its('first_district.href') { is_expected.to include('/minnesota/st.-paul/foo/') }
        its('first_district.city_state.text') { is_expected.to eq('St. Paul, MN') }
        its('first_district.text') { is_expected.to include('3 schools') }
        its('second_district.text') { is_expected.to include('2 schools') }
        its('third_district.text') { is_expected.to match(/1 school$/) }
      end
    end

    context 'with six districts' do
      let!(:districts) do
        [5, 25, 15, 10, 30, 40].each do |num_schools|
          FactoryGirl.create_on_shard(:mn, :district, name: 'foo', city: 'St. Paul', state: 'MN', num_schools: num_schools)
        end
      end
      it { is_expected.to have_largest_districts_section }
      with_subject :largest_districts_section do
        its('districts.length') { is_expected.to eq(5) }
        its('first_district.text') { is_expected.to include('40 schools') }
        its('fifth_district.text') { is_expected.to include('10 schools') }
      end
    end
  end
end

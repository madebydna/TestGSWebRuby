require 'spec_helper'
require 'features/page_objects/district_home_page'
require 'features/examples/page_examples'
require 'features/examples/top_rated_schools_section_examples'
require 'features/examples/footer_examples'

describe 'District Home Page' do
  before { skip }
  let!(:district) { create(:district, state: 'ca', city: 'Alameda', name: 'Alameda City Unified' ,home_page_url:'www.alameda.k12.ca.us') }
  after { clean_dbs :us_geo, :gs_schooldb, :ca }
  subject(:page_object) do
    visit district_path('california', 'alameda', 'alameda-city-unified')
    DistrictHomePage.new
  end
  include_examples 'should have a footer'
  it { is_expected.to have_link('District website' ,href:"http://www.alameda.k12.ca.us")}
  context 'District website url with http'  do
    let(:district) { create(:district, state: 'ca', city: 'Alameda', name: 'Alameda City Unified' ,home_page_url:'http://www.alameda.k12.ca.us') }
    it { is_expected.to have_link('District website' ,href:"http://www.alameda.k12.ca.us")}
  end
  context 'District website url with https'  do
    let(:district) { create(:district, state: 'ca', city: 'Alameda', name: 'Alameda City Unified' ,home_page_url:'https://www.alameda.k12.ca.us') }
    it { is_expected.to have_link('District website' ,href:"https://www.alameda.k12.ca.us")}
  end
  it { is_expected.to have_email_signup_section }
  describe 'breadcrumbs' do
    it { is_expected.to have_breadcrumbs }
    its('first_breadcrumb.title') { is_expected.to have_text('California') }
    its('first_breadcrumb') { is_expected.to have_link('California', href: "/california/") }
    its('second_breadcrumb.title') { is_expected.to have_text('Alameda') }
    its('second_breadcrumb') { is_expected.to have_link('Alameda', href: "/california/alameda/") }
  end

  describe 'Top rated schools' do
    let!(:top_rated_schools) do
      (1..5).map do |nearby_school_number|
        shard = :ca
        s = FactoryGirl.create_on_shard(shard, :alameda_high_school, district_id: district.id, name: "Nearby School #{nearby_school_number}")
        FactoryGirl.create_on_shard(shard, :overall_rating_school_metadata, school_id: s.id, meta_value: nearby_school_number + 5)
        s
      end
    end
    let(:heading_object) { district }
    it_behaves_like 'page with top rated schools section'
  end

end

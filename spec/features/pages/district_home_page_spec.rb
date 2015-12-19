require 'spec_helper'
require 'features/page_objects/district_home_page'
require_relative '../examples/page_examples'

describe 'District Home Page' do
  before do
    create(:district, state: 'ca', city: 'Alameda', name: 'Alameda City Unified')
    visit district_path('california', 'alameda', 'alameda-city-unified')
  end
  after { clean_dbs :us_geo }
  subject(:page_object) { DistrictHomePage.new }

  it { is_expected.to have_email_signup_section }
  describe 'breadcrumbs' do
    it { is_expected.to have_breadcrumbs }
    its('first_breadcrumb.title') { is_expected.to have_text('California') }
    its('first_breadcrumb') { is_expected.to have_link('California', href: "/california/") }
    its('second_breadcrumb.title') { is_expected.to have_text('Alameda') }
    its('second_breadcrumb') { is_expected.to have_link('Alameda', href: "/california/alameda/") }
  end
end

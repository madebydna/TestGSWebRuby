require 'spec_helper'
require_relative 'district_home_page'
require_relative '../examples/page_examples'

describe 'District Home Page' do
  before do
    create(:district, state: 'ca', city: 'Alameda', name: 'Alameda City Unified')
    visit district_path('california', 'alameda', 'alameda-city-unified')
  end
  after { clean_dbs :us_geo }
  subject(:page_object) { DistrictHomePage.new }

  it { is_expected.to have_email_signup_section }

end

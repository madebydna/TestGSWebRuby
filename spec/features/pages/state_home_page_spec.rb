require 'spec_helper'
require 'features/examples/page_examples'
require 'features/contexts/state_home_contexts'
require 'features/examples/footer_examples'
require 'features/contexts/cities_contexts'
require 'features/examples/footer_examples'

describe 'State Home Page' do
  describe 'basic state home page' do
    before do
      create(:city, state: 'mn', name: 'St. Paul')
      stub_request(:post, /\/solr\/main\/select/).to_return(status: 200, body: "{}", headers: {})
      visit state_path('minnesota')
    end
    after { clean_dbs :us_geo }
    subject { StateHomePage.new }

    include_examples 'should have a footer'
  end

end

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
      stub_request(:post, "#{ENV_GLOBAL['solr.ro.server.url']}select?wt=json").to_return(status: 200, body: "{}", headers: {})
      visit state_path('minnesota')
    end
    after { clean_dbs :us_geo }
    subject { StateHomePage.new }

    include_examples 'should have a footer'
    with_shared_context 'Largest cities on state home' do
      include_example 'should have a link with', text: 'ST. PAUL', href: '/minnesota/st.-paul/'
    end
  end

end

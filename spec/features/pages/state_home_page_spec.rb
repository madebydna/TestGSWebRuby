require 'spec_helper'
require_relative '../examples/page_examples'
require_relative '../contexts/state_home_contexts'
require_relative '../examples/footer_examples'
require 'features/contexts/cities_contexts'

describe 'State Home Page' do
  describe 'basic state home page' do
    before do
      create(:city, state: 'mn', name: 'St. Paul')
      visit state_path('minnesota')
    end
    after { clean_dbs :us_geo }
    subject { StateHomePage.new }

    with_shared_context 'Largest cities on state home' do
      include_example 'should have a link with', text: 'ST. PAUL', href: '/minnesota/st.-paul/'
    end

    include_example 'should have state footer'
  end

  context 'washington-dc' do
    include_context 'Given the following city(s) are in the db', [{state: 'dc', name: 'washington'}]
    with_shared_context 'when visiting /washington-dc' do
      include_example 'should have redirected to', '/washington-dc/washington/'
    end
  end
end
